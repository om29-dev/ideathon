from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import google.generativeai as genai
import os
import json
import re
from typing import Optional, List, Dict
from dotenv import load_dotenv
import pandas as pd
from datetime import datetime, timedelta
import io

# Load environment variables
load_dotenv()

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

try:
    # Preferred: package import when running as a package (python -m backend.main)
    from backend.config import GEMINI_API_KEY
    from backend.tips.service import generate_daily_tip
except Exception:
    # Fallback: adjust sys.path when running main.py directly from the backend/ folder
    import sys, os
    repo_root = os.path.dirname(os.path.dirname(__file__))
    if repo_root not in sys.path:
        sys.path.insert(0, repo_root)
    from backend.config import GEMINI_API_KEY
    from backend.tips.service import generate_daily_tip

class ChatRequest(BaseModel):
    message: str
    max_tokens: Optional[int] = 1000
    temperature: Optional[float] = 0.7

class ChatResponse(BaseModel):
    response: str
    status: str
    has_expenses: Optional[bool] = False

class DailyTipRequest(BaseModel):
    category: Optional[str] = "general"
    notification_type: Optional[str] = "standard"
    excel_data: Optional[str] = None

class ExpenseItem(BaseModel):
    date: str
    description: str
    amount: float
    category: Optional[str] = "Other"

def extract_expenses_from_text(text: str, ai_response: str) -> List[ExpenseItem]:
    """Extract expenses from user input and AI response using regex patterns"""
    expenses = []
    
    # Enhanced expense patterns
    patterns = [
        # Pattern 1: "cost me X" or "amount was X"
        r'(?:cost\s+me|amount\s+was|for|paid|spent)\s*(?:rs\.?|₹|dollars?|\$)?\s*(\d+(?:\.\d{2})?)',
        # Pattern 2: "X rs/rupees/dollars"
        r'(\d+(?:\.\d{2})?)\s*(?:rs\.?|rupees?|dollars?|₹|\$)',
        # Pattern 3: Currency symbols first
        r'(?:₹|\$)\s*(\d+(?:\.\d{2})?)',
        # Pattern 4: "of X rs" format
        r'of\s+(\d+(?:\.\d{2})?)\s*(?:rs\.?|rupees?)',
    ]
    
    # Extract text for processing - focus on user input primarily
    user_text = text.lower()
    
    # Find expense items with their amounts
    expense_items = []
    
    # Look for specific items mentioned before amounts
    item_patterns = [
        (r'(?:took\s+)?flight(?:\s+(?:which|for))?.*?(\d+)(?:\s*rs)?', 'Flight'),
        (r'ate\s+at\s+(?:airport|restaurant|hotel).*?(?:for|cost).*?(\d+)(?:\s*rs)?', 'Food & Dining'),
        (r'flight.*?(?:for|cost).*?(\d+)(?:\s*rs)?', 'Flight'),
        (r'airport.*?food.*?(\d+)(?:\s*rs)?', 'Food & Dining'),
        (r'bought\s+([^0-9]+?)(?:\s+(?:of|for|cost))\s+(\d+)(?:\s*rs)?', None),  # Dynamic item name
        (r'(\w+(?:\s+\w+)?)\s+(?:of|for|cost|price)\s+(\d+)(?:\s*rs)?', None),  # Generic item
        (r'spent.*?₹?(\d+).*?on\s+([^.\n]+)', None),  # "spent 150 on books"
    ]
    
    # Process specific patterns first
    for pattern, category in item_patterns:
        matches = re.finditer(pattern, user_text, re.IGNORECASE)
        for match in matches:
            if category:
                # Fixed category items
                amount = float(match.group(1))
                description = category.replace('Food & Dining', 'Airport Food')
                if category == 'Flight':
                    description = 'Flight Ticket'
                expense_items.append({
                    'description': description,
                    'amount': amount,
                    'category': category if category != 'Flight' else 'Transportation'
                })
            else:
                # Dynamic item name - handle different group patterns
                if len(match.groups()) >= 2:
                    # Check if this is "spent X on Y" pattern
                    if 'spent' in pattern:
                        amount = float(match.group(1))
                        item_name = match.group(2).strip()
                    else:
                        item_name = match.group(1).strip()
                        amount = float(match.group(2))
                    
                    expense_items.append({
                        'description': item_name.title(),
                        'amount': amount,
                        'category': categorize_expense(item_name)
                    })
    
    # Additional manual parsing for your specific format
    # Handle "flight for X rs and ate at airport for Y rs"
    flight_match = re.search(r'flight.*?for.*?(\d+).*?rs', user_text, re.IGNORECASE)
    if flight_match and not any(item['description'] in ['Flight Ticket', 'Flight'] for item in expense_items):
        amount = float(flight_match.group(1))
        expense_items.append({
            'description': 'Flight Ticket',
            'amount': amount,
            'category': 'Transportation'
        })
    
    airport_food_match = re.search(r'ate.*?airport.*?for.*?(\d+).*?rs', user_text, re.IGNORECASE)
    if airport_food_match and not any('Airport' in item['description'] for item in expense_items):
        amount = float(airport_food_match.group(1))
        expense_items.append({
            'description': 'Airport Food',
            'amount': amount,
            'category': 'Food & Dining'
        })
    
    # If specific patterns didn't work, fall back to general extraction
    if not expense_items:
        # Extract all amounts
        amounts = []
        for pattern in patterns:
            matches = re.finditer(pattern, user_text, re.IGNORECASE)
            for match in matches:
                amounts.append(float(match.group(1)))
        
        # Extract descriptions
        descriptions = []
        desc_patterns = [
            r'(?:bought|purchased|got|ate\s+at|went\s+to|paid\s+for|took)\s+([^0-9₹$]+?)(?:\s+(?:for|amount\s+was|cost|paid|spent|of))',
            r'(?:i|we)\s+(?:bought|purchased|got|ate\s+at|went\s+to|paid\s+for|took)\s+([^0-9₹$]+)',
        ]
        
        for pattern in desc_patterns:
            matches = re.finditer(pattern, user_text, re.IGNORECASE)
            for match in matches:
                desc = match.group(1).strip()
                if len(desc) > 2:
                    descriptions.append(desc)
        
        # Combine amounts and descriptions
        for i, amount in enumerate(amounts):
            desc = descriptions[i] if i < len(descriptions) else f"Expense {i+1}"
            expense_items.append({
                'description': desc.title(),
                'amount': amount,
                'category': categorize_expense(desc)
            })
    
    # Try to extract date information
    date_patterns = [
        r'yesterday',
        r'today',
        r'last (?:week|month)',
    ]
    
    extracted_date = datetime.now().strftime("%Y-%m-%d")  # Default to today
    
    for pattern in date_patterns:
        match = re.search(pattern, user_text, re.IGNORECASE)
        if match:
            if 'yesterday' in match.group().lower():
                extracted_date = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
            elif 'today' in match.group().lower():
                extracted_date = datetime.now().strftime("%Y-%m-%d")
            elif 'last week' in match.group().lower():
                extracted_date = (datetime.now() - timedelta(weeks=1)).strftime("%Y-%m-%d")
            break
    
    # Create expense objects
    for item in expense_items:
        expenses.append(ExpenseItem(
            date=extracted_date,
            description=item['description'],
            amount=item['amount'],
            category=item['category']
        ))
    
    return expenses

def categorize_expense(description: str) -> str:
    """Categorize expense based on description"""
    description = description.lower()
    
    if any(word in description for word in ['food', 'restaurant', 'hotel', 'ate', 'dinner', 'lunch', 'breakfast', 'airport']):
        return "Food & Dining"
    elif any(word in description for word in ['transport', 'uber', 'taxi', 'bus', 'train', 'flight', 'plane']):
        return "Transportation"
    elif any(word in description for word in ['clothes', 'shirt', 'shoes', 'umbrella', 'personal', 'headset', 'headphone']):
        return "Personal Items"
    elif any(word in description for word in ['medicine', 'doctor', 'hospital', 'health']):
        return "Healthcare"
    elif any(word in description for word in ['movie', 'entertainment', 'game', 'cinema']):
        return "Entertainment"
    elif any(word in description for word in ['grocery', 'shopping', 'market']):
        return "Shopping"
    else:
        return "Other"

def create_excel_response(expenses: List[ExpenseItem]) -> bytes:
    """Create Excel file from expenses list"""
    if not expenses:
        return None
    
    # Create DataFrame
    df = pd.DataFrame([{
        'Date': expense.date,
        'Description': expense.description,
        'Amount (₹)': expense.amount,
        'Category': expense.category
    } for expense in expenses])
    
    # Create Excel file in memory
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='Expenses', index=False)
        
        # Get the workbook and worksheet
        workbook = writer.book
        worksheet = writer.sheets['Expenses']
        
        # Format the worksheet
        from openpyxl.styles import Font, PatternFill, Alignment
        
        # Header formatting
        header_font = Font(bold=True, color="FFFFFF")
        header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
        
        for cell in worksheet[1]:
            cell.font = header_font
            cell.fill = header_fill
            cell.alignment = Alignment(horizontal="center")
        
        # Auto-adjust column widths
        for column in worksheet.columns:
            max_length = 0
            column_letter = column[0].column_letter
            for cell in column:
                try:
                    if len(str(cell.value)) > max_length:
                        max_length = len(str(cell.value))
                except:
                    pass
            adjusted_width = min(max_length + 2, 50)
            worksheet.column_dimensions[column_letter].width = adjusted_width
        
        # Add total row
        total_row = len(df) + 2
        worksheet[f'C{total_row}'] = "Total:"
        worksheet[f'D{total_row}'] = f"₹{df['Amount (₹)'].sum():.2f}"
        worksheet[f'C{total_row}'].font = Font(bold=True)
        worksheet[f'D{total_row}'].font = Font(bold=True)
    
    output.seek(0)
    return output.getvalue()

@app.get("/")
async def root():
    return {"message": "FastAPI backend with Gemini API is running!"}

@app.post("/chat", response_model=ChatResponse)
async def chat_with_gemini(request: ChatRequest):
    try:
        if not GEMINI_API_KEY:
            raise HTTPException(status_code=500, detail="Gemini API key not configured")
        
        # Initialize the model
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        # Generate response
        response = model.generate_content(
            request.message,
            generation_config=genai.types.GenerationConfig(
                max_output_tokens=request.max_tokens,
                temperature=request.temperature,
            )
        )
        
        ai_response = response.text
        
        # Check if the message contains expense information
        expense_keywords = ['spent', 'bought', 'paid', 'cost', 'amount', 'expense', 'money', 'rupees', '₹', '$']
        has_expenses = any(keyword in request.message.lower() for keyword in expense_keywords)
        
        excel_data = None
        if has_expenses:
            # Extract expenses from the user message and AI response
            expenses = extract_expenses_from_text(request.message, ai_response)
            
            if expenses:
                # Create Excel file
                excel_bytes = create_excel_response(expenses)
                if excel_bytes:
                    import base64
                    excel_data = base64.b64encode(excel_bytes).decode('utf-8')
                    
                    # Enhance AI response with expense summary
                    total_amount = sum(exp.amount for exp in expenses)
                    expense_summary = f"\n\n📊 **Expense Summary:**\n"
                    expense_summary += f"• Total Amount: ₹{total_amount:.2f}\n"
                    expense_summary += f"• Number of Items: {len(expenses)}\n"
                    expense_summary += "• Expenses extracted and Excel file generated!\n"
                    expense_summary += "Click the download button below to get your expense report."
                    
                    ai_response += expense_summary
        
        return ChatResponse(
            response=ai_response,
            status="success",
            has_expenses=has_expenses and excel_data is not None,
            excel_data=excel_data
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

@app.post("/download-excel")
async def download_excel(request: dict):
    """Download Excel file endpoint using POST"""
    try:
        import base64
        excel_data = request.get('excel_data')
        if not excel_data:
            raise HTTPException(status_code=400, detail="No excel data provided")
            
        excel_bytes = base64.b64decode(excel_data)
        
        # Create BytesIO object
        excel_io = io.BytesIO(excel_bytes)
        
        return StreamingResponse(
            excel_io,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={
                "Content-Disposition": f"attachment; filename=expenses_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx",
                "Content-Length": str(len(excel_bytes))
            }
        )
    except Exception as e:
        print(f"Download error: {str(e)}")  # Debug log
        raise HTTPException(status_code=500, detail=f"Error downloading file: {str(e)}")

@app.get("/download/excel")
async def download_excel_get():
    """Download Excel file endpoint using GET"""
    try:
        # Sample expenses for demo
        sample_expenses = [
            ExpenseItem(date="2025-08-20", description="Gaming Purchase", amount=1500.0, category="Entertainment"),
            ExpenseItem(date="2025-08-20", description="Restaurant Bill", amount=850.0, category="Food & Dining"),
            ExpenseItem(date="2025-08-20", description="Subscription", amount=299.0, category="Entertainment")
        ]
        
        # Generate Excel file
        excel_bytes = create_excel_response(sample_expenses)
        
        if excel_bytes:
            return Response(
                content=excel_bytes,
                media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                headers={"Content-Disposition": "attachment; filename=expenses.xlsx"}
            )
        else:
            raise HTTPException(status_code=500, detail="Failed to generate Excel file")
            
    except Exception as e:
        print(f"Download error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error downloading file: {str(e)}")

@app.get("/download/csv")
async def download_csv_get():
    """Download CSV file endpoint using GET"""
    try:
        # Sample expenses for demo
        sample_expenses = [
            ExpenseItem(date="2025-08-20", description="Gaming Purchase", amount=1500.0, category="Entertainment"),
            ExpenseItem(date="2025-08-20", description="Restaurant Bill", amount=850.0, category="Food & Dining"),
            ExpenseItem(date="2025-08-20", description="Subscription", amount=299.0, category="Entertainment")
        ]
        
        # Generate CSV content
        csv_content = "Date,Description,Amount,Category\n"
        for expense in sample_expenses:
            csv_content += f"{expense.date},{expense.description},{expense.amount},{expense.category}\n"
        
        return Response(
            content=csv_content.encode('utf-8'),
            media_type="text/csv",
            headers={"Content-Disposition": "attachment; filename=expenses.csv"}
        )
            
    except Exception as e:
        print(f"CSV download error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error downloading CSV file: {str(e)}")

@app.post("/generate-excel")
async def generate_excel(request: dict):
    """Generate and return Excel file as base64"""
    try:
        user_message = request.get('message', '')
        
        # Extract expenses from message
        expenses = extract_expenses_from_text(user_message, '')
        
        if not expenses:
            return {"error": "No expenses found in message"}
            
        # Generate Excel
        excel_bytes = create_excel_response(expenses)
        if excel_bytes:
            import base64
            excel_data = base64.b64encode(excel_bytes).decode('utf-8')
            return {
                "success": True,
                "excel_data": excel_data,
                "expenses_count": len(expenses),
                "total_amount": sum(exp.amount for exp in expenses)
            }
        else:
            return {"error": "Failed to generate Excel"}
            
    except Exception as e:
        print(f"Generate Excel error: {str(e)}")
        return {"error": str(e)}

@app.post("/view-summary")
async def view_summary(request: dict):
    try:
        excel_data = request.get("excel_data")
        if not excel_data:
            return {"error": "No excel data provided"}
        
        # For demo purposes, return mock data based on the excel_data
        # In a real implementation, you would decode and parse the Excel data
        mock_expenses = [
            {
                "date": "2025-08-21",
                "description": "Books",
                "category": "Education", 
                "amount": 150.0
            },
            {
                "date": "2025-08-21",
                "description": "Snacks",
                "category": "Food & Dining",
                "amount": 80.0
            },
            {
                "date": "2025-08-21",
                "description": "Bus fare",
                "category": "Transportation",
                "amount": 25.0
            },
            {
                "date": "2025-08-20",
                "description": "Coffee",
                "category": "Food & Dining",
                "amount": 120.0
            },
            {
                "date": "2025-08-20",
                "description": "Stationery",
                "category": "Education",
                "amount": 200.0
            }
        ]
        
        total_amount = sum(expense["amount"] for expense in mock_expenses)
        
        return {
            "expenses": mock_expenses,
            "total": total_amount,
            "currency": "INR",
            "excel_data": excel_data
        }
        
    except Exception as e:
        print(f"View summary error: {str(e)}")
        return {"error": str(e)}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "gemini_configured": bool(GEMINI_API_KEY)}


@app.get("/daily-tip")
async def daily_tip():
    """Return a short daily tip (cached per day)."""
    try:
        tip_data = generate_daily_tip()
        return {
            "status": "success", 
            "tip": tip_data,
            "timestamp": datetime.now().isoformat(),
            "cached": tip_data.get("date") == datetime.utcnow().strftime("%Y-%m-%d")
        }
    except Exception as e:
        # Return fallback tip on error
        fallback_tip = {
            "date": datetime.utcnow().strftime("%Y-%m-%d"),
            "tip": "Save ₹50 daily to have ₹18,250 in a year! Small habits lead to big results."
        }
        return {
            "status": "error", 
            "message": str(e),
            "tip": fallback_tip,
            "timestamp": datetime.now().isoformat(),
            "cached": False
        }

@app.post("/daily-tip")
async def daily_tip_varied(request: DailyTipRequest):
    """Return a varied daily tip based on category."""
    try:
        tip_data = generate_daily_tip(category=request.category)
        return {
            "status": "success", 
            "tip": tip_data,
            "category": request.category,
            "timestamp": datetime.now().isoformat(),
            "cached": tip_data.get("date") == datetime.utcnow().strftime("%Y-%m-%d")
        }
    except Exception as e:
        # Return fallback tip on error
        fallback_tip = {
            "date": datetime.utcnow().strftime("%Y-%m-%d"),
            "tip": "Save ₹50 daily to have ₹18,250 in a year! Small habits lead to big results."
        }
        return {
            "status": "error", 
            "tip": fallback_tip,
            "category": request.category,
            "message": str(e),
            "timestamp": datetime.now().isoformat(),
            "cached": False
        }

@app.get("/test-excel")
async def test_excel():
    """Test Excel generation endpoint"""
    try:
        # Create sample expenses
        sample_expenses = [
            ExpenseItem(date="2025-08-20", description="Flight", amount=4000.0, category="Transportation"),
            ExpenseItem(date="2025-08-20", description="Airport Food", amount=1200.0, category="Food & Dining"),
            ExpenseItem(date="2025-08-20", description="Headsets", amount=2000.0, category="Personal Items")
        ]
        
        # Generate Excel
        excel_bytes = create_excel_response(sample_expenses)
        if excel_bytes:
            import base64
            excel_data = base64.b64encode(excel_bytes).decode('utf-8')
            return {"excel_data": excel_data[:100] + "...", "size": len(excel_data)}
        else:
            return {"error": "Failed to generate Excel"}
            
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

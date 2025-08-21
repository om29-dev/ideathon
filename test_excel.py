import requests
import json

# Test the chat endpoint with expense data
def test_expense_chat():
    url = "http://localhost:8004/chat"
    
    test_message = "yesterday i took flight which cost me 4000 rs also i ate at airport for 1200 rs i bought headsets of 2000rs"
    
    data = {
        "message": test_message,
        "max_tokens": 1000,
        "temperature": 0.7
    }
    
    try:
        print("Testing expense chat...")
        response = requests.post(url, json=data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Chat response successful!")
            print(f"Has expenses: {result.get('has_expenses', False)}")
            print(f"Excel data available: {bool(result.get('excel_data'))}")
            
            if result.get('excel_data'):
                print("✅ Excel data generated successfully!")
                print(f"Excel data length: {len(result['excel_data'])}")
                
                # Test download
                test_download(result['excel_data'])
            else:
                print("❌ No Excel data generated")
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Exception: {str(e)}")

def test_download(excel_data):
    url = "http://localhost:8004/download-excel"
    
    data = {
        "excel_data": excel_data
    }
    
    try:
        print("\nTesting Excel download...")
        response = requests.post(url, json=data)
        
        if response.status_code == 200:
            print("✅ Excel download successful!")
            print(f"File size: {len(response.content)} bytes")
            
            # Save the file for verification
            with open("test_expenses.xlsx", "wb") as f:
                f.write(response.content)
            print("✅ Excel file saved as 'test_expenses.xlsx'")
        else:
            print(f"❌ Download error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Download exception: {str(e)}")

if __name__ == "__main__":
    test_expense_chat()

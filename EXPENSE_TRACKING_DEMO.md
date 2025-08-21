# 🎉 Expense Tracking Feature Demo

## 🆕 What's New!

Your Gemini Chat Application now includes **automatic expense tracking and Excel generation**! 

## ✨ How It Works

When you mention expenses in your chat, the AI will:
1. **Extract expense details** (amounts, descriptions, dates)
2. **Categorize expenses** automatically
3. **Generate a formatted Excel file** for download
4. **Provide expense summaries**

## 🧪 Try These Examples

Copy and paste these examples to test the expense tracking:

### Example 1: Simple Expenses
```
Yesterday I ate at a hotel for ₹200 and bought an umbrella for ₹300
```

### Example 2: Multiple Expenses
```
Today I spent ₹150 on groceries, ₹50 on bus transport, and ₹80 on medicine
```

### Example 3: Mixed Format
```
I paid $25 for lunch, bought clothes for ₹500, and spent 100 rupees on a movie ticket
```

### Example 4: Detailed Expenses
```
Last week I went to the restaurant and the amount was ₹450, then I purchased a new shirt for ₹800, and got an Uber for ₹120
```

## 📊 Excel File Features

The generated Excel file includes:
- **Date** of expense
- **Description** with smart categorization
- **Amount** in ₹ (Indian Rupees)
- **Category** (Food & Dining, Transportation, Personal Items, Healthcare, Entertainment, Other)
- **Professional formatting** with headers and totals
- **Auto-sized columns** for better readability

## 🎯 Supported Formats

The AI recognizes various formats:
- **Currency symbols**: ₹, $, Rs.
- **Amount phrases**: "amount was", "cost", "paid", "spent", "for"
- **Time references**: "yesterday", "today", "last week"
- **Purchase verbs**: "bought", "purchased", "ate at", "went to"

## 🚀 How to Use

1. **Start chatting** with expense-related messages
2. **Look for the download button** 📊 that appears with bot responses
3. **Click "Download Excel Report"** to get your formatted expense file
4. **Open in Excel/Google Sheets** to view and edit

## 🔧 Technical Details

- **Backend**: FastAPI with pandas and openpyxl for Excel generation
- **Frontend**: React with axios for file downloads
- **AI Integration**: Gemini AI processes natural language expenses
- **Smart Parsing**: Regex patterns extract amounts and descriptions
- **Auto-categorization**: Built-in expense category detection

## 💡 Tips for Best Results

1. **Be specific** with amounts and items
2. **Include time references** for accurate dating
3. **Use common terms** for better categorization
4. **Mention currency** for clarity (₹, $, rupees)

## 🎉 Ready to Try?

Start your React frontend at http://localhost:3000 and begin tracking your expenses with AI! 

The system is running on:
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8003
- **API Docs**: http://localhost:8003/docs

import React, { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [messages, setMessages] = useState([
    {
      id: 1,
      text: "Hello! I'm your AI Finance Assistant powered by Google's Gemini. I'm here to help you manage your finances as a student! 💰\n\n💡 **Features**:\n• Track your daily expenses\n• Get investment advice for students\n• Learn about SIP and stock market basics\n• Set financial goals\n\nTry saying: 'I spent ₹150 on books and ₹80 on snacks today'",
      sender: 'bot',
      timestamp: new Date().toLocaleTimeString(),
      hasExpenses: false
    }
  ]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState('checking');
  const [userTokens, setUserTokens] = useState(150);
  const [niftyData, setNiftyData] = useState([]);
  const [theme, setTheme] = useState('light');
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    checkBackendHealth();
    generateNiftyData();
  }, []);

  const generateNiftyData = () => {
    const data = [];
    let value = 18500;
    for (let i = 0; i < 20; i++) {
      value += Math.random() * 100 - 50;
      data.push({
        time: `${9 + Math.floor(i / 4)}:${(i % 4) * 15}`.padStart(2, '0'),
        value: Math.round(value)
      });
    }
    setNiftyData(data);
  };

  const checkBackendHealth = async () => {
    try {
      const response = await axios.get('http://localhost:8004/health');
      if (response.data.gemini_configured) {
        setConnectionStatus('connected');
      } else {
        setConnectionStatus('no-api-key');
      }
    } catch (error) {
      setConnectionStatus('disconnected');
    }
  };

  const cycleTheme = () => {
    const themes = ['light', 'dark', 'market'];
    const currentIndex = themes.indexOf(theme);
    const nextIndex = (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  };

  const renderMarkdown = (text) => {
    return text
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.*?)\*/g, '<em>$1</em>')
      .replace(/•/g, '•')
      .replace(/💰/g, '💰')
      .replace(/₹(\d+)/g, '<span class="currency">₹$1</span>')
      .split('\n').map((line, index) => (
        <span key={index}>
          <span dangerouslySetInnerHTML={{__html: line}} />
          {index < text.split('\n').length - 1 && <br />}
        </span>
      ));
  };

  const downloadExcel = async (excelData) => {
    try {
      const response = await axios.post('http://localhost:8004/download-excel', {
        excel_data: excelData
      }, {
        responseType: 'blob',
      });

      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      
      const now = new Date();
      const timestamp = now.toISOString().slice(0, 19).replace(/:/g, '-');
      link.setAttribute('download', `student_expenses_${timestamp}.xlsx`);
      
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
      
      setUserTokens(prev => prev + 10);
    } catch (error) {
      console.error('Error downloading Excel file:', error);
      alert('Failed to download Excel file. Please try again.');
    }
  };

  const downloadCSV = async (excelData) => {
    try {
      // Convert Excel data to CSV format
      const csvData = convertToCSV(excelData);
      
      // Create a Blob object with CSV data
      const blob = new Blob([csvData], { type: 'text/csv;charset=utf-8;' });
      
      // Create download link
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      
      // Generate filename with current timestamp
      const now = new Date();
      const timestamp = now.toISOString().slice(0, 19).replace(/:/g, '-');
      link.setAttribute('download', `expenses_${timestamp}.csv`);
      
      // Trigger download
      document.body.appendChild(link);
      link.click();
      link.remove();
      
      // Clean up
      URL.revokeObjectURL(url);
      
      setUserTokens(prev => prev + 5);
    } catch (error) {
      console.error('Error downloading CSV file:', error);
      alert('Failed to download CSV file. Please try again.');
    }
  };

  const convertToCSV = (excelData) => {
    if (!excelData || !excelData.expenses) return "Date,Category,Amount,Description\n";
    
    let csvContent = "Date,Category,Amount,Description\n";
    
    excelData.expenses.forEach(expense => {
      const date = expense.date || new Date().toISOString().split('T')[0];
      const category = expense.category || 'Uncategorized';
      const amount = expense.amount || 0;
      const description = expense.description || '';
      
      csvContent += `"${date}","${category}",${amount},"${description}"\n`;
    });
    
    return csvContent;
  };

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!inputMessage.trim() || isLoading) return;

    const userMessage = {
      id: Date.now(),
      text: inputMessage,
      sender: 'user',
      timestamp: new Date().toLocaleTimeString()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputMessage('');
    setIsLoading(true);

    try {
      const response = await axios.post('http://localhost:8004/chat', {
        message: inputMessage,
        max_tokens: 1000,
        temperature: 0.7
      });

      const botMessage = {
        id: Date.now() + 1,
        text: response.data.response,
        sender: 'bot',
        timestamp: new Date().toLocaleTimeString(),
        hasExpenses: response.data.has_expenses,
        excelData: response.data.excel_data
      };

      setMessages(prev => [...prev, botMessage]);
      setUserTokens(prev => prev + 5);
    } catch (error) {
      const errorMessage = {
        id: Date.now() + 1,
        text: `Error: ${error.response?.data?.detail || 'Failed to connect to server'}`,
        sender: 'error',
        timestamp: new Date().toLocaleTimeString()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
      inputRef.current?.focus();
    }
  };

  const getStatusBadge = () => {
    switch (connectionStatus) {
      case 'connected':
        return <span className="status-badge connected">✓ Connected</span>;
      case 'no-api-key':
        return <span className="status-badge warning">⚠ API Key Required</span>;
      case 'disconnected':
        return <span className="status-badge disconnected">✗ Backend Offline</span>;
      default:
        return <span className="status-badge checking">⟳ Checking...</span>;
    }
  };

  const NiftyChart = () => {
    if (niftyData.length === 0) return null;
    
    const values = niftyData.map(d => d.value);
    const min = Math.min(...values);
    const max = Math.max(...values);
    const range = max - min;
    
    const lastValue = values[values.length - 1];
    const firstValue = values[0];
    const isPositive = lastValue >= firstValue;
    
    return (
      <div className="nifty-chart">
        <div className="chart-header">
          <h4>NIFTY 50</h4>
          <span className={`chart-value ${isPositive ? 'positive' : 'negative'}`}>
            {lastValue} {isPositive ? '↗' : '↘'}
          </span>
        </div>
        <div className="chart-container">
          <svg width="100%" height="80" className="chart-svg">
            <polyline
              fill="none"
              stroke={isPositive ? '#4cc9f0' : '#f94144'}
              strokeWidth="2"
              points={niftyData.map((d, i) => 
                `${(i / (niftyData.length - 1)) * 100},${80 - ((d.value - min) / range) * 70}`
              ).join(' ')}
            />
          </svg>
        </div>
        <div className="chart-times">
          {niftyData.filter((d, i) => i % 4 === 0).map(d => (
            <span key={d.time}>{d.time}</span>
          ))}
        </div>
      </div>
    );
  };

  const getThemeIcon = () => {
    switch (theme) {
      case 'light': return '☀️';
      case 'dark': return '🌙';
      case 'market': return '📈';
      default: return '🎨';
    }
  };

  return (
    <div className={`App theme-${theme}`}>
      <div className="theme-background">
        {theme === 'market' && (
          <>
            <div className="stock-grid"></div>
            <div className="market-icons">
              <div className="market-icon">📈</div>
              <div className="market-icon">📉</div>
              <div className="market-icon">💹</div>
              <div className="market-icon">📊</div>
            </div>
          </>
        )}
      </div>
      
      <header className="app-header">
        <div className="ai-model-title">
          <span className="ai-icon">🤖</span>
          <h1>AI Finance Assistant</h1>
        </div>
        <div className="header-controls">
          {getStatusBadge()}
          <button className="theme-switcher" onClick={cycleTheme}>
            {getThemeIcon()} Theme
          </button>
        </div>
      </header>

      <div className="app-body">
        <div className="user-profile">
          <div className="profile-card">
            <div className="profile-image">
              <img src="https://i.pravatar.cc/100?img=32" alt="User" />
              <div className="online-status"></div>
            </div>
            <div className="profile-info">
              <h3>Student User</h3>
              <p>Finance Enthusiast</p>
            </div>
            <div className="token-counter">
              <div className="tokens">
                <span className="token-icon">🪙</span>
                <span className="token-count">{userTokens} Tokens</span>
              </div>
              <div className="progress-bar">
                <div className="progress" style={{width: `${(userTokens % 100)}%`}}></div>
                <span className="progress-text">Level {Math.floor(userTokens/100) + 1}</span>
              </div>
            </div>
          </div>
          
          <div className="nifty-section">
            <NiftyChart />
          </div>
          
          <div className="financial-tips">
            <h4>💡 Daily Tip</h4>
            <p>Save ₹50 daily to have ₹18,250 in a year!</p>
          </div>
        </div>

        <div className="chat-container">
          <div className="messages-container">
            {messages.map((message) => (
              <div key={message.id} className={`message ${message.sender}`}>
                <div className="message-content">
                  <div className="message-text">
                    {renderMarkdown(message.text)}
                  </div>
                  {message.hasExpenses && message.excelData && (
                    <div className="excel-download">
                      <button 
                        onClick={() => downloadExcel(message.excelData)}
                        className="download-btn"
                      >
                        📊 Download Excel
                      </button>
                      <button 
                        onClick={() => downloadCSV(message.excelData)}
                        className="download-btn csv-btn"
                      >
                        📝 Download CSV
                      </button>
                      <button 
                        onClick={() => {/* Add view Excel functionality */}}
                        className="view-btn"
                      >
                        👁️ View Summary
                      </button>
                    </div>
                  )}
                  <div className="message-time">{message.timestamp}</div>
                </div>
              </div>
            ))}
            {isLoading && (
              <div className="message bot">
                <div className="message-content">
                  <div className="typing-indicator">
                    <span>AI is thinking</span>
                    <div className="typing-dots">
                      <span></span>
                      <span></span>
                      <span></span>
                    </div>
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          <form className="input-form" onSubmit={sendMessage}>
            <div className="input-container">
              <input
                ref={inputRef}
                type="text"
                value={inputMessage}
                onChange={(e) => setInputMessage(e.target.value)}
                placeholder="Ask about student budgeting, investments, or track expenses..."
                disabled={isLoading || connectionStatus === 'disconnected'}
                className="message-input"
              />
              <button 
                type="submit" 
                disabled={isLoading || !inputMessage.trim() || connectionStatus === 'disconnected'}
                className="send-button"
              >
                {isLoading ? '⏳' : '📤'}
              </button>
            </div>
            <div className="input-suggestions">
              <span>Try: </span>
              <button type="button" onClick={() => setInputMessage("I spent ₹150 on books and ₹80 on snacks today")}>Track Expense</button>
              <button type="button" onClick={() => setInputMessage("How can I save money as a student?")}>Saving Tips</button>
              <button type="button" onClick={() => setInputMessage("Explain SIP in simple terms")}>SIP Explanation</button>
            </div>
          </form>
        </div>
      </div>

      {connectionStatus === 'no-api-key' && (
        <div className="setup-info">
          <p>To use this app, you need to:</p>
          <ol>
            <li>Get a Gemini API key from Google AI Studio</li>
            <li>Create a <code>.env</code> file in the backend folder</li>
            <li>Add your API key: <code>GEMINI_API_KEY=your_key_here</code></li>
            <li>Restart the backend server</li>
          </ol>
        </div>
      )}

      {connectionStatus === 'disconnected' && (
        <div className="setup-info error">
          <p>Backend server is not running. Please start it with:</p>
          <code>cd backend && python main.py</code>
        </div>
      )}
    </div>
  );
}

export default App;
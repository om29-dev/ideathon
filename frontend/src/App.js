import React, { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [messages, setMessages] = useState([
    {
      id: 1,
      text: "Hello! I'm powered by Google's Gemini AI. Ask me anything!\n\n💡 **New Feature**: I can now track your expenses! Try saying something like:\n• \"Yesterday I ate at a hotel for ₹200 and bought an umbrella for ₹300\"\n• \"I spent ₹150 on groceries and ₹50 on transport today\"\n\nI'll automatically generate an Excel file for your expenses! 📊",
      sender: 'bot',
      timestamp: new Date().toLocaleTimeString(),
      hasExpenses: false
    }
  ]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState('checking');
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
  }, []);

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

  const renderMarkdown = (text) => {
    // Simple markdown-like rendering
    return text
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')  // Bold text
      .replace(/\*(.*?)\*/g, '<em>$1</em>')              // Italic text
      .replace(/•/g, '•')                                // Bullet points
      .replace(/📊/g, '📊')                              // Emojis
      .replace(/₹(\d+)/g, '<span class="currency">₹$1</span>') // Currency highlighting
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

      // Create blob link to download
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      
      // Generate filename with current timestamp
      const now = new Date();
      const timestamp = now.toISOString().slice(0, 19).replace(/:/g, '-');
      link.setAttribute('download', `expenses_${timestamp}.xlsx`);
      
      // Trigger download
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Error downloading Excel file:', error);
      alert('Failed to download Excel file. Please try again.');
    }
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

  return (
    <div className="App">
      <header className="app-header">
        <h1>AI Finance Buddy</h1>
        {getStatusBadge()}
      </header>

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
                      📊 Download Excel Report
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
                  <span></span>
                  <span></span>
                  <span></span>
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
              placeholder="Type your message here..."
              disabled={isLoading || connectionStatus === 'disconnected'}
              className="message-input"
            />
            <button 
              type="submit" 
              disabled={isLoading || !inputMessage.trim() || connectionStatus === 'disconnected'}
              className="send-button"
            >
              {isLoading ? '⟳' : '→'}
            </button>
          </div>
        </form>
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

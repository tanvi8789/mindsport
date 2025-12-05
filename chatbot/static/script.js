let currentSessionId = null;
let currentUserId = '001';

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    loadSessions();
    document.getElementById('user-id').addEventListener('change', function() {
        currentUserId = this.value;
        loadSessions();
    });
});

async function loadSessions() {
    const userId = document.getElementById('user-id').value;
    currentUserId = userId;
    
    try {
        const response = await fetch(`/api/sessions/${userId}`);
        const data = await response.json();
        
        if (data.sessions) {
            displaySessions(data.sessions);
        }
    } catch (error) {
        console.error('Error loading sessions:', error);
    }
}

function displaySessions(sessions) {
    const sessionsList = document.getElementById('sessions-list');
    sessionsList.innerHTML = '';
    
    sessions.forEach(session => {
        const sessionElement = document.createElement('div');
        sessionElement.className = 'session-item';
        if (session.session_id === currentSessionId) {
            sessionElement.classList.add('active');
        }
        
        sessionElement.innerHTML = `
            <div class="session-name">${session.session_name}</div>
            <div class="session-date">${new Date(session.created_at).toLocaleDateString()}</div>
        `;
        
        sessionElement.onclick = () => loadSession(session.session_id, session.session_name);
        sessionsList.appendChild(sessionElement);
    });
}

async function loadSession(sessionId, sessionName) {
    currentSessionId = sessionId;
    document.getElementById('session-name').textContent = sessionName;
    
    // Update active session in sidebar
    document.querySelectorAll('.session-item').forEach(item => {
        item.classList.remove('active');
    });
    event.target.closest('.session-item').classList.add('active');
    
    try {
        const response = await fetch(`/api/messages/${sessionId}`);
        const data = await response.json();
        
        if (data.messages) {
            displayMessages(data.messages);
        }
    } catch (error) {
        console.error('Error loading messages:', error);
    }
}

function displayMessages(messages) {
    const chatMessages = document.getElementById('chat-messages');
    chatMessages.innerHTML = '';
    
    if (messages.length === 0) {
        chatMessages.innerHTML = `
            <div class="welcome-message">
                <p>Welcome! I'm your mental health assistant. How can I support you today?</p>
            </div>
        `;
        return;
    }
    
    messages.forEach(message => {
        addMessageToChat(message.content, message.role);
    });
    
    scrollToBottom();
}

function addMessageToChat(content, role) {
    const chatMessages = document.getElementById('chat-messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${role}-message`;
    messageDiv.innerHTML = `
        <div class="message-content">${content}</div>
    `;
    chatMessages.appendChild(messageDiv);
    scrollToBottom();
}

function scrollToBottom() {
    const chatMessages = document.getElementById('chat-messages');
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

async function sendMessage() {
    const messageInput = document.getElementById('message-input');
    const message = messageInput.value.trim();
    
    if (!message) return;
    
    // Disable input while sending
    messageInput.disabled = true;
    document.getElementById('send-btn').disabled = true;
    
    // Add user message to chat immediately
    addMessageToChat(message, 'user');
    messageInput.value = '';
    
    // Show typing indicator
    showTypingIndicator();
    
    try {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: currentUserId,
                session_id: currentSessionId,
                message: message
            })
        });
        
        const data = await response.json();
        
        if (data.error) {
            throw new Error(data.error);
        }
        
        // Update session ID if this was a new session
        if (!currentSessionId) {
            currentSessionId = data.session_id;
            loadSessions(); // Reload sessions to show the new one
        }
        
        // Add assistant response to chat
        addMessageToChat(data.response, 'assistant');
        
    } catch (error) {
        console.error('Error sending message:', error);
        addMessageToChat('Sorry, I encountered an error. Please try again.', 'assistant');
    } finally {
        // Re-enable input
        messageInput.disabled = false;
        document.getElementById('send-btn').disabled = false;
        hideTypingIndicator();
        messageInput.focus();
    }
}

function showTypingIndicator() {
    const chatMessages = document.getElementById('chat-messages');
    const typingDiv = document.createElement('div');
    typingDiv.id = 'typing-indicator';
    typingDiv.className = 'typing-indicator show';
    typingDiv.textContent = 'Assistant is typing...';
    chatMessages.appendChild(typingDiv);
    scrollToBottom();
}

function hideTypingIndicator() {
    const typingDiv = document.getElementById('typing-indicator');
    if (typingDiv) {
        typingDiv.remove();
    }
}

function createNewSession() {
    currentSessionId = null;
    document.getElementById('session-name').textContent = 'New Chat';
    document.getElementById('chat-messages').innerHTML = `
        <div class="welcome-message">
            <p>Welcome! I'm your mental health assistant. How can I support you today?</p>
        </div>
    `;
    
    // Remove active class from all sessions
    document.querySelectorAll('.session-item').forEach(item => {
        item.classList.remove('active');
    });
    
    document.getElementById('message-input').focus();
}
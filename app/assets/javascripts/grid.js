// app/javascript/packs/grid.js

document.addEventListener('DOMContentLoaded', () => {
    const chatInput = document.getElementById('chat-input');
    const sendButton = document.getElementById('send-button');
    const chatMessages = document.getElementById('chat-messages');

    function addMessage() {
        const messageText = chatInput.value.trim();
        if (messageText) {
            const messageDiv = document.createElement('div');
            messageDiv.classList.add('chat-message');
            messageDiv.textContent = messageText;
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
            chatInput.value = '';
        }
    }

    sendButton.addEventListener('click', addMessage);

    chatInput.addEventListener('keypress', (event) => {
        if (event.key === 'Enter') {
            addMessage();
        }
    });
});

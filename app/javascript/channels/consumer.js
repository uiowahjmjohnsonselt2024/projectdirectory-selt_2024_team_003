class Consumer {
    constructor(url) {
        this.url = url;
        this.socket = null;
    }

    connect() {
        this.socket = new WebSocket(this.url);
        this.socket.onopen = () => {
            console.log("WebSocket connection established");
        };
        this.socket.onclose = () => {
            console.log("WebSocket connection closed");
        };
        this.socket.onerror = (error) => {
            console.error("WebSocket error:", error);
        };
    }

    disconnect() {
        if (this.socket) {
            this.socket.close();
            this.socket = null;
        }
    }

    sendMessage(message) {
        if (this.socket && this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(message);
        } else {
            console.error("WebSocket is not open. Cannot send message.");
        }
    }
}

export default Consumer;
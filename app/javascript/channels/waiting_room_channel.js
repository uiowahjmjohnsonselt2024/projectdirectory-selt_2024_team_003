import consumer from "./consumer";

consumer.subscriptions.create("WaitingRoomChannel", {
    connected() {
        console.log("Connected to the Waiting Room!");
        // You can execute actions on connection, e.g., show a waiting room UI
    },

    disconnected() {
        console.log("Disconnected from the Waiting Room!");
    },

    received(data) {
        // Handle messages broadcast from the server
        if (data.message) {
            alert(data.message); // Example: Show a message when event starts
            window.location.href = "/start_game"; // Redirect if needed
        }
    },
});
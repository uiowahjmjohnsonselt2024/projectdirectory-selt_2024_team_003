console.log("hello")
import consumer from '../../assets/javascripts/consumer'

consumer.subscriptions.create("ArenaChannel", {
    connected() {
        console.log("Connected to ArenaChannel");
    },

    disconnected() {
        console.log("Disconnected from ArenaChannel");
    },

    received(data) {
        console.log("Received data:", data);
        // Handle data received from the server
    },
});

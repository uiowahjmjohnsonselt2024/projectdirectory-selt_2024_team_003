//= require actioncable
//= require consumer

window.App || (window.App = {});

App.cable = ActionCable.createConsumer();

console.log("App.cable has now been initialized for Arena:", App.cable);

App.cable.subscriptions.create("ArenaChannel", {
    connected() {
        //console.log("Connected to ArenaChannel");
    },

    disconnected() {
        console.log("Disconnected from ArenaChannel");
    },

    received(data) {
        console.log("Received data:", data);
        // Handle data received from the server
    },
});

import consumer from "./consumer";

consumer.subscriptions.create("ArenaChannel", {
    received(data) {
        if (data.redirect) {
            window.location.href = data.redirect;
        }
    },
});
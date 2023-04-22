"use strict";

class RemoteSync {

  constructor() {
    this.boundEvents = false;
    this.sendEvents = true;
  }

  connect() {
    let url = location.origin.replace(/^http/, "ws") + "/socket";
    let conn = new WebSocket(url);

    conn.addEventListener("open", () => this.bindEvents());

    conn.addEventListener("message", (event) => this.onMessage(event));

    conn.addEventListener("error", (event) => {
      console.error("WebSocket connection failed.", event);
      setTimeout(() => this.connect(), 2000);
    });

    this.conn = conn;
  }

  bindEvents() {
    if(this.boundEvents) { return; }
    this.boundEvents = true;

    for(const eventName of ["next", "prev", "slidechange"]) {
      shower.addEventListener(eventName, () => this.showerEvent(eventName));
    }
  }

  onMessage(event) {
    let msg = JSON.parse(event.data);
    this.sendEvents = false;

    try {
      switch(msg.eventName) {
        case "next":
          shower.next();
          break;

        case "prev":
          shower.prev();
          break;

        case "slidechange":
          if(shower.activeSlideIndex != msg.activeSlideIndex) {
            shower.goTo(msg.activeSlideIndex);
          }

          break;
      }
    } finally {
      this.sendEvents = true;
    }
  }

  showerEvent(eventName) {
    if(!this.sendEvents) { return; }

    let activeSlideIndex = shower.activeSlideIndex;
    let msg = JSON.stringify({ eventName, activeSlideIndex });

    this.conn.send(msg);
  }

}

document.addEventListener('DOMContentLoaded', function() {
  window.remoteSync = new RemoteSync();
  window.remoteSync.connect();
});

// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import "./ether_scan_socket.js"
import socket from "./ether_scan_socket.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

let modal = document.getElementsByClassName("payment-modal")[0];
let makePaymentBtn = document.getElementById("makePayment");
let span = document.getElementsByClassName("close")[0];
const hashfield = document.getElementById("hashfield");

let channel = socket.channel("room:lobby", {})
channel.join()
  .receive("reply", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })



makePaymentBtn.onclick = function() {
    value = hashfield.value;
    if(value.length >  20) {
        let value = hashfield.value
        makePaymentBtn.innerText = "Processing..."
        channel.push("ping", {
            hash: value
        });
    } else {
        alert("Please enter a valid ethereum tx hash!");
    }
}

channel.on("phx_reply", function(msg) {
    const response = msg.response;
    if(Object.keys(response).length > 2 && response.eths !== "") {
        modal.style.display = "block";
        let resp = msg.response;
        document.getElementsByClassName('digit')[0].innerHTML = Number.parseFloat(resp.eths).toFixed(6);
        document.getElementsByClassName('count')[0].innerHTML = resp.confirmations

        if(Number.parseInt(resp.confirmations) > 10) {
            document.getElementById('signal_img').setAttribute('src', "./images/check-mark.png")
        }
    } else {
        // Disconnect Websocket Connection
        // channel.leave()
        // modal.style.display = "none"
        let error = "No transaction record of hash ID found."
        makePaymentBtn.innerText = "Make Payment";
    }
    return;
});


// When the user clicks on <span> (x), close the modal
span.onclick = function() {
  modal.style.display = "none";
  makePaymentBtn.innerText = "Make Payment"
  channel.leave()
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
    makePaymentBtn.innerText = "Make Payment"
    channel.leave()
  }
}

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

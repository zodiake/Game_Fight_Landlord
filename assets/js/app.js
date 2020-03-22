// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:

import { Elm } from "../elm/src/Game.elm"
import socket from "./socket"

const elmDiv = document.getElementById("elm-main")
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

var app =Elm.Game.init({ node: elmDiv,flags:{csrfToken:csrfToken}})

let channel;
let player;
app.ports.joinRoom.subscribe(joinRoom)
function joinRoom(roomId){
    channel = socket.channel(`room:${roomId}`, {})
    channel.join()
        .receive("ok",res=>{app.ports.receive(res)})
}



/*
for liveview
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.connect()
*/
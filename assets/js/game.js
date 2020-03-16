import Game from './socket.js'
import $ from 'jquery'
let game = new Game();

$('#create_game').click(function () {
    game.createRoom("1")
});

class Game {
  constructor() {
    let socket = new Socket("/socket", {
      params: {
        token: window.userToken
      }
    });

    socket.connect()
    this.socket = socket;
  }

  createRoom(room) {
    $.post(`/game/${room}`, res => {
      if (res == "ok") {
        console.log("room created")
        this.room = room;
      } else {
        console.log("room create fail")
      }
    });
  }

  joinRoom(room) {
    let channel = socket.channel("game:1", {})
    channel.join()
      .receive("ok", resp => {
        console.log("Joined successfully", resp)
      })
      .receive("error", resp => {
        console.log("Unable to join", resp)
      })
  }
}
export default Game;

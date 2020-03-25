port module WebSocket exposing (getReady, joinRoom, receive)


port joinRoom : String -> Cmd msg


port getReady : () -> Cmd msg


port receive : (String -> msg) -> Sub msg

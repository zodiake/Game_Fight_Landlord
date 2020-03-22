port module WebSocket exposing (joinRoom, receive)


port getReady : String -> Cmd msg


port joinRoom : String -> Cmd msg


port receive : (String -> msg) -> Sub msg

module Hall exposing (Model, Msg, init, view)

--Model

import Html exposing (Html, button, div, input, text)
import Html.Events exposing (onClick, onInput)


type alias Model =
    { content : String }


type Msg
    = CreateRoom
    | JoinRoom
    | Change String


init : ( Model, Cmd Msg )
init =
    ( { content = "" }, Cmd.none )



-- update


viewContent : Model -> Html Msg
viewContent model =
    div []
        [ button [ onClick CreateRoom ] [ text "create" ]
        , button [ onClick JoinRoom ] [ text "join" ]
        , input [ onInput Change ] []
        ]


view : Model -> Html Msg
view model =
    viewContent model

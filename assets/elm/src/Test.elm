module Test exposing (main)

import Browser
import Debug exposing (toString)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


type alias Model =
    Int


init : Model
init =
    1


type Msg
    = Click


view : Model -> Html Msg
view model =
    div [] [ button [ onClick Click ] [] ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Click ->
            model + 1

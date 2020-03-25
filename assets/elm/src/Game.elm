module Game exposing (main)

import Browser
import Card exposing (Card, getCardUnicode, testCards)
import Html exposing (Html, button, div, input, li, section, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick, onInput)
import Http exposing (header)
import Json.Decode as Decode exposing (decodeString, string)
import Json.Encode as Encode
import List exposing (map)
import WebSocket as WS



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = sub }



-- MODEL


type alias Room =
    { roomId : String }


type alias Game =
    { playerReference : String, handsCard : List String, lastCard : List String }


type alias Flags =
    { csrfToken : String }


type alias Model =
    { room : Room, game : Game, errs : List String, token : String }


init : Flags -> ( Model, Cmd msg )
init flags =
    let
        room =
            Room ""

        game =
            Game "" [] []
    in
    ( Model room game [] flags.csrfToken, Cmd.none )


type Msg
    = CreateRoom
    | JoinRoom
    | GetReady
    | Player String
    | CreateRoomResponse (Result Http.Error String)
    | UpdateRoomId String



-- UPDATE


fetch : Model -> String -> Cmd Msg
fetch model id =
    Http.request
        { url = "/game/" ++ id
        , method = "post"
        , body = Http.jsonBody <| encodeCreate <| id
        , expect = Http.expectString CreateRoomResponse
        , timeout = Nothing
        , tracker = Nothing
        , headers = [ header "x-csrf-token" model.token ]
        }


encodeCreate : String -> Encode.Value
encodeCreate id =
    Encode.object [ ( "roomId", Encode.string id ) ]


createRoom : Model -> String -> Cmd Msg
createRoom model id =
    fetch model id


errDecoder : Http.Error -> List String
errDecoder err =
    case err of
        _ ->
            [ "server error" ]


updateErrors : List String -> Model -> Model
updateErrors errs model =
    { model | errs = List.append errs model.errs }


updateRoomId : String -> Room -> Room
updateRoomId id room =
    { room | roomId = id }


updateRoom : (Room -> Room) -> Model -> Model
updateRoom fn model =
    { model | room = fn model.room }


updateGameReference : String -> Game -> Game
updateGameReference ref game =
    { game | playerReference = ref }


updateGame : (Game -> Game) -> Model -> Model
updateGame fn model =
    { model | game = fn model.game }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateRoom ->
            ( model, createRoom model model.room.roomId )

        JoinRoom ->
            ( model, WS.joinRoom model.room.roomId )

        UpdateRoomId id ->
            ( updateRoom (updateRoomId id) model, Cmd.none )

        CreateRoomResponse (Ok result) ->
            ( updateErrors [ "create room" ] model, Cmd.none )

        CreateRoomResponse (Err err) ->
            ( updateErrors (errDecoder err) model, Cmd.none )

        Player ok ->
            ( updateErrors [ "joined" ] model, Cmd.none )

        GetReady ->
            ( model, WS.getReady () )



--sub


sub : Model -> Sub Msg
sub model =
    WS.receive Player



--view


viewErrors : String -> Html Msg
viewErrors errs =
    div [] [ text errs ]


view : Model -> Html Msg
view model =
    section []
        [ button [ onClick CreateRoom ] [ text "createRoom" ]
        , button [ onClick JoinRoom ] [ text "joinRoom" ]
        , button [ onClick GetReady ] [ text "get_ready" ]
        , input [ class "form-control", onInput UpdateRoomId ] []
        , div [] (List.map viewErrors model.errs)
        , div [] [ text model.token ]
        ]

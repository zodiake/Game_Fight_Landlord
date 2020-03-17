module Login exposing (..)

import Html exposing (Html, button, div, form, h1, input, label)
import Html.Attributes exposing (class, for, id, placeholder, type_)
import Http
import Json.Decode exposing (Decoder, decodeString, field, int, string, succeed)
import Json.Decode.Pipeline exposing (required)



-- Model


init : ( Account, Cmd Msg )
init =
    ( Account "" "", Cmd.none )


type alias Account =
    { name : String, password : String }


type alias Response =
    { status : String }


type alias Model =
    { account : Maybe Account, error : String }


accountDecoder : Decoder Response
accountDecoder =
    succeed Response |> required "status" string



--Msg


type Msg
    = Submit
    | LoadAccount (Result Http.Error Response)



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit ->
            ( model, login )

        LoadAccount (Ok res) ->
            if res.status == "ok" then
                ( model, Cmd.none )

            else
                ( model, Cmd.none )


enterHall : Model -> Html Msg
enterHall model =
    div [] []


login :Model-> Cmd Msg
login =
    Http.get
        { url = "/login"
        , expect = Http.expectJson LoadAccount accountDecoder
        }



--view


view : Model -> Html Msg
view model =
    div []
        [ form [ class "form-signi" ]
            [ h1 [ class "h3 mb-3 font-weight-normal" ] []
            , label [ class "sr-only", for "name" ] []
            , input [ class "form-control", placeholder "UserName", id "name" ] []
            , label [ class "sr-only", for "password" ] []
            , input [ class "form-control", placeholder "Password", id "password" ] []
            , button [ class "btn btn-lg btn-primary btn-block", type_ "submit" ] []
            ]
        ]

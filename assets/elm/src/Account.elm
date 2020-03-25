module Account exposing (..)

import Html exposing (Html, button, div, form, h1, input, label)
import Html.Attributes exposing (class, for, id, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as D



-- Model


type alias Account =
    { name : String, password : String }


type alias Response =
    { reasons : List String }


type alias Model =
    { account : Account, response : Response }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


initModel : Model
initModel =
    let
        account =
            { name = "", password = "" }

        response =
            { reasons = [] }
    in
    { account = account, response = response }


responseDecoder : Decoder Response
responseDecoder =
    succeed Response |> required "reasons" (list string)



--Msg


type Field
    = Name
    | Password


type Msg
    = Update Field String
    | SubmissionResult (Result Http.Error Response)
    | Submit



-- update


updateAccount : Field -> String -> Account -> Account
updateAccount field value account =
    case field of
        Name ->
            { account | name = value }

        Password ->
            { account | password = value }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update field a ->
            ( { model | account = updateAccount field a model.account }, Cmd.none )

        Submit ->
            ( model, login model )

        SubmissionResult (Ok res) ->
            ( { model | response = res }, Cmd.none )

        SubmissionResult (Err err) ->
            ( { model | response = Response [ "wrong password or username" ] }, Cmd.none )


encodeBody : Model -> D.Value
encodeBody model =
    D.object [ ( "name", D.string model.account.password ) ]


login : Model -> Cmd Msg
login model =
    Http.post
        { url = "/login"
        , body = Http.jsonBody (encodeBody model)
        , expect = Http.expectJson SubmissionResult responseDecoder
        }



--view


inputText : String -> Field -> Html Msg
inputText name field =
    input [ class "form-control", placeholder name, id name, onInput (Update field) ] []


viewError : List String -> Html Msg
viewError errors =
    let
        error =
            List.map (\err -> div [] [ err ]) errors
    in
    div [] [ error ]


view : Model -> Html Msg
view model =
    div []
        [ form [ class "form-signi" ]
            [ h1 [ class "h3 mb-3 font-weight-normal" ] []
            , label [ class "sr-only", for "name" ] []
            , inputText "name" Name
            , label [ class "sr-only", for "password" ] []
            , inputText "password" Password
            , button [ class "btn btn-lg btn-primary btn-block", type_ "submit", onClick Submit ] []
            ]
        , viewError model.response.reasons
        ]

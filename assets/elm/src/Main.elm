module Main exposing (main)

import Account
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation
import Html exposing (Html, div)
import Platform.Cmd as Subscriptions
import Routes exposing (Route)
import Url exposing (Url)



-- MAIN


type Page
    = Account Account.Model
    | Game
    | Hall
    | NotFound


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subs
        , onUrlRequest = Visit
        , onUrlChange = Routes.match >> NewRoute
        }



-- MODEL


type alias Model =
    { page : Page, navigationKey : Navigation.Key }


initModel : Navigation.Key -> Model
initModel nk =
    { page = NotFound, navigationKey = nk }



-- init


init : () -> Url -> Navigation.Key -> ( Model, Cmd msg )
init () url key =
    ( initModel key, Cmd.none )


type Msg
    = NewRoute (Maybe Routes.Route)
    | Visit UrlRequest
    | AccountMsg Account.Msg



--view


view : Model -> Document Msg
view model =
    let
        ( title, body ) =
            viewContent model.page
    in
    { title = title, body = [ body ] }


viewContent : Page -> ( String, Html Msg )
viewContent page =
    case page of
        Account model ->
            ( "Account", Account.view model |> Html.map AccountMsg )

        Game ->
            ( "game", div [] [] )

        Hall ->
            ( "hall", div [] [] )

        NotFound ->
            ( "notfound", div [] [] )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NewRoute (Just Account) ->
            let
                ( account, cmd ) =
                    Account.init
            in
            ( { model | page = Account account }, Cmd.map AccountMsg cmd )

        _ ->
            ( model, Cmd.none )


subs : Model -> Sub Msg
subs model =
    Sub.none

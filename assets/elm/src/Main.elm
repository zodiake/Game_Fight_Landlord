module Main exposing (main)

import Account
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation
import Game
import Hall
import Html exposing (Html, div, text)
import Routes
import Url exposing (Url)



-- MAIN


type Page
    = Account Account.Model
    | Game
    | Hall Hall.Model
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


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url key =
    setNewPage (Routes.match url) (initModel key)


type Msg
    = NewRoute (Maybe Routes.Route)
    | Visit UrlRequest
    | AccountMsg Account.Msg
    | HallMsg Hall.Msg



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

        Hall model ->
            ( "hall", Hall.view model |> Html.map HallMsg )

        NotFound ->
            ( "notfound", div [] [ text "123" ] )


setNewPage : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
setNewPage maybe model =
    case maybe of
        Just Routes.Account ->
            let
                ( accountModel, cmd ) =
                    Account.init
            in
            ( { model | page = Account accountModel }, Cmd.map AccountMsg cmd )

        Just (Routes.Game roomId) ->
            let
                ( accountModel, cmd ) =
                    Account.init
            in
            ( { model | page = Account accountModel }, Cmd.map AccountMsg cmd )

        Just Routes.Hall ->
            let
                ( hallModel, cmd ) =
                    Hall.init
            in
            ( { model | page = Hall hallModel }, Cmd.map HallMsg cmd )

        _ ->
            ( model, Cmd.none )



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( NewRoute maybeRoute, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


subs : Model -> Sub Msg
subs model =
    Sub.none

module Game exposing (..)

import Browser
import Card exposing (Card, getCardUnicode, testCards)
import Html exposing (Html, button, div, li, section, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List exposing (map)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { inHands : List Card, last : List Card }


init : Model
init =
    { inHands = testCards, last = testCards }



-- UPDATE


type Msg
    = SelectCard Card
    | DealCards
    | Pass


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectCard selected ->
            { model | inHands = updateCards toggleSelected selected model.inHands }

        DealCards ->
            { model | inHands = dropSelected model.inHands }

        Pass ->
            { model | inHands = dropSelected model.inHands }


dropSelected : List Card -> List Card
dropSelected cards =
    List.filter
        (\card ->
            if card.selected then
                False

            else
                True
        )
        cards


toggleSelected : Card -> Card
toggleSelected card =
    { card | selected = not card.selected }


updateCards : (Card -> Card) -> Card -> List Card -> List Card
updateCards fun selected cards =
    List.map
        (\card ->
            if card.color == selected.color && card.value == selected.value then
                fun card

            else
                card
        )
        cards


cardView : Card -> Html Msg
cardView card =
    let
        selectedClass =
            if card.selected == True then
                "card-selected"

            else
                ""

        fontColor =
            if card.color == "Diamond" || card.color == "Heart" then
                "red-card"

            else
                "black-card"
    in
    li [ class "card", class selectedClass, class fontColor, onClick (SelectCard card) ] [ text (getCardUnicode card) ]



-- VIEW


cardsView : List Card -> Html Msg
cardsView inHands =
    ul [ class "hands" ]
        (List.map cardView inHands)


poolsView : List Card -> Html Msg
poolsView last =
    ul [ class "pools" ]
        (List.map cardView last)


buttonView : Html Msg
buttonView =
    div []
        [ button [ onClick DealCards ]
            [ text "deal"
            ]
        , button
            [ onClick Pass ]
            [ text "pass"
            ]
        ]


view : Model -> Html Msg
view model =
    section []
        [ div []
            [ poolsView model.last
            ]
        , buttonView
        , div []
            [ cardsView model.inHands
            ]
        ]

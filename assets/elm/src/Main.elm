module Main exposing (main)

import Browser
import Card exposing (Card, getCardUnicode, testCards)
import Html exposing (Html, button, div, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import List exposing (map)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { cards : List Card }


init : Model
init =
    { cards = testCards }



-- UPDATE


type Msg
    = SelectCard Card


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectCard selected ->
            { model | cards = updateCards toggleSelected selected model.cards }


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
    in
    li [ class "card", class selectedClass, onClick (SelectCard card) ] [ text (getCardUnicode card) ]


cardsView : Model -> Html Msg
cardsView model =
    ul [class "hands"]
        (List.map cardView model.cards)



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ cardsView model
        ]

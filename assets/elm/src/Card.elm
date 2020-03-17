module Card exposing (Card, getCardUnicode, testCards)

import Array exposing (Array, fromList, get)
import List
import Maybe exposing (Maybe)


spades : Array String
spades =
    fromList [ "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮", "🂡", "🂢" ]


hearts : Array String
hearts =
    fromList [ "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂽", "🂾", "🂱", "🂲" ]


diamonds : Array String
diamonds =
    fromList [ "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃍", "🃎", "🃁", "🃂" ]


clubs : Array String
clubs =
    fromList [ "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃝", "🃞", "🃑", "🃒" ]


jokers : Array String
jokers =
    fromList [ "🃏", "🃟" ]


type alias Card =
    { color : String
    , value : Int
    , selected : Bool
    }


getCardUnicode : Card -> String
getCardUnicode card =
    let
        res =
            case card.color of
                "Diamond" ->
                    get card.value diamonds

                "Club" ->
                    get card.value clubs

                "Heart" ->
                    get card.value hearts

                "Spade" ->
                    get card.value spades

                "RedJoker" ->
                    get 0 jokers

                "WhiteJoker" ->
                    get 1 jokers

                _ ->
                    Just ""
    in
    case res of
        Just a ->
            a

        Nothing ->
            ""


testCards : List Card
testCards =
    [ Card "Spade" 1 False, Card "Club" 1 False, Card "Heart" 1 False, Card "Diamond" 1 False ]


getCardsUnicode : List Card -> List String
getCardsUnicode cards =
    List.map getCardUnicode cards

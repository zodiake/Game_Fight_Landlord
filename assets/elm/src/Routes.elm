module Routes exposing (Route, match)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Login
    | Hall
    | Game Int


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Login Parser.top
        , Parser.map Hall (Parser.s "hall")
        , Parser.map Game (Parser.s "game" </> Parser.int)
        ]


match : Url -> Maybe Route
match url =
    Parser.parse routes url

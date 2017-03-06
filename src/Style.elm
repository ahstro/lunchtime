module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body)


rem =
    Css.rem


css =
    stylesheet
        [ html
            [ fontSize (px 14) ]
        , body
            [ backgroundColor (hex "f6f6f6")
            ]
        ]

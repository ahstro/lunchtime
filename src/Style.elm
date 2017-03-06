module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body)
import Css.Namespace


type CssClasses
    = Wrapper
    | Changes
    | Change


rem =
    Css.rem


namespace =
    "lunchtime"


changePadding =
    (rem 0.2)


css =
    (stylesheet << Css.Namespace.namespace namespace)
        [ html
            [ fontSize (px 14) ]
        , body
            [ backgroundColor (hex "f6f6f6")
            ]
        , class Wrapper
            [ backgroundColor (hex "ffffff")
            , maxWidth (rem 64)
            , padding (rem 2)
            , margin2 (rem 4) auto
            , border3 (px 1) solid (hex "a7d7f9")
            ]
        , class Changes
            [ backgroundColor (hex "f9f9f9")
            , overflowWrap breakWord
            , padding changePadding
            , border3 (px 1) solid (hex "aaaaaa")
            ]
        ]

module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body)
import Css.Namespace


type CssClasses
    = SiteCode
    | Wrapper
    | Changes
    | Change
    | Title
    | Black
    | Blue
    | Red


namespace =
    "lunchtime"


css =
    let
        rem =
            Css.rem

        changePadding =
            (rem 0.2)

        fgColor =
            (hex "252525")

        blue =
            (hex "0645ad")
    in
        (stylesheet << Css.Namespace.namespace namespace)
            [ html
                [ fontSize (px 14) ]
            , body
                [ backgroundColor (hex "f6f6f6")
                ]
            , class SiteCode
                [ fontFamily monospace
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
                , padding2 changePadding (rem 0)
                , border3 (px 1) solid (hex "aaaaaa")
                ]
            , class Change
                [ displayFlex
                , alignItems center
                , cursor default
                , hover [ backgroundColor (hex "f1f1f1") ]
                ]
            , class Title
                [ color blue
                , textDecoration none
                , marginLeft (em 0.5)
                , hover [ textDecoration underline ]
                ]
            , class Black [ color fgColor ]
            , class Blue [ color blue ]
            , class Red [ color (hex "ba0000") ]
            ]

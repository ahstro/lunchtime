module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body, a)
import Css.Namespace


type CssClasses
    = SiteCode
    | Wrapper
    | Changes
    | Change
    | Title
    | Green
    | Black
    | Diff
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
                , displayFlex
                , height (vh 100)
                ]
            , a
                [ textDecoration none
                ]
            , class SiteCode
                [ fontFamily monospace
                ]
            , class Wrapper
                [ backgroundColor (hex "ffffff")
                , flexDirection column
                , displayFlex
                , maxWidth (rem 64)
                , flexGrow (int 1)
                , padding (rem 2)
                , margin2 (rem 4) auto
                , border3 (px 1) solid (hex "a7d7f9")
                ]
            , class Changes
                [ backgroundColor (hex "f9f9f9")
                , overflowWrap breakWord
                , overflow hidden
                , flexGrow (int 1)
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
                , marginLeft (em 0.5)
                , hover [ textDecoration underline ]
                ]
            , class Diff
                [ fontSize (em 0.7)
                , flexGrow (int 1)
                , textAlign right
                , marginRight changePadding
                ]
            , class Green [ color (hex "02660c") ]
            , class Black [ color fgColor ]
            , class Blue [ color blue ]
            , class Red [ color (hex "ba0000") ]
            ]

module Lunchtime.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (html, body, a)
import Css.Namespace


type CssClasses
    = CheckboxLabel
    | CheckboxInput
    | CheckboxTitle
    | Checkboxes
    | SiteCode
    | Settings
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


webkitScrollbar =
    pseudoElement "-webkit-scrollbar"


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
            [ everything
                [ boxSizing borderBox
                , before [ boxSizing borderBox ]
                , after [ boxSizing borderBox ]
                ]
            , html
                [ fontSize (px 14) ]
            , body
                [ backgroundColor (hex "f6f6f6")
                , displayFlex
                , height (vh 100)
                ]
            , a
                [ textDecoration none
                ]
            , class CheckboxLabel
                [ displayFlex
                , alignItems center
                , marginLeft (em 0.5)
                ]
            , class CheckboxInput
                [ marginRight (em 0.3)
                ]
            , class CheckboxTitle
                [ fontWeight bold
                ]
            , class Checkboxes
                [ displayFlex
                , alignItems center
                , marginLeft (em 1)
                , firstChild [ marginLeft (em 0) ]
                ]
            , class SiteCode
                [ fontFamily monospace
                ]
            , class Settings
                [ displayFlex
                , marginBottom (em 0.5)
                , flexShrink (int 0)
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
                , webkitScrollbar [ display none ]
                , overflowWrap breakWord
                , overflowY auto
                , overflowX hidden
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
                , margin2 (em 0) (em 0.5)
                , visited [ color (hex "663366") ]
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

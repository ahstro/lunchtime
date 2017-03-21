module Lunchtime.View exposing (view)

import Html exposing (Html, label, input, span, div, text, a)
import Html.Attributes exposing (checked, title, href, type_)
import Html.Events exposing (onMouseEnter, onMouseLeave, onClick)
import Html.CssHelpers
import Json.Encode
import Helpers exposing (juxt)
import Lunchtime.Model exposing (Model, Settings)
import Lunchtime.Update exposing (Msg(..))
import Lunchtime.Change exposing (Change, ChangeType(..))
import Lunchtime.Style as Style
import Lunchtime.User exposing (User(..), UserType(..))


{ class } =
    Html.CssHelpers.withNamespace Style.namespace


view : Model -> Html Msg
view model =
    div [ class [ Style.Wrapper ] ]
        [ viewSettings model.settings
        , viewChanges model.changes
        ]


viewSettings : Settings -> Html Msg
viewSettings settings =
    div
        [ class [ Style.Settings ] ]
        [ div [ class [ Style.Checkboxes ] ]
            [ viewCheckboxTitle "Change types:"
            , viewChangeCheckbox Edit settings.changeTypes
            , viewChangeCheckbox New settings.changeTypes
            , viewChangeCheckbox Log settings.changeTypes
            , viewChangeCheckbox Categorize settings.changeTypes
            ]
        , div [ class [ Style.Checkboxes ] ]
            [ viewCheckboxTitle "User types:"
            , viewUserCheckbox Anonymous settings.userTypes
            , viewUserCheckbox Human settings.userTypes
            , viewUserCheckbox Bot settings.userTypes
            ]
        ]


viewCheckboxTitle : String -> Html Msg
viewCheckboxTitle txt =
    span
        [ class [ Style.CheckboxTitle ] ]
        [ text txt ]


viewChangeCheckbox : ChangeType -> List ChangeType -> Html Msg
viewChangeCheckbox changeType changeTypes =
    viewCheckbox
        (List.member changeType changeTypes)
        (ToggleChangeType changeType)
        (toString changeType)


viewUserCheckbox : UserType -> List UserType -> Html Msg
viewUserCheckbox userType userTypes =
    viewCheckbox
        (List.member userType userTypes)
        (ToggleUserType userType)
        (toString userType)


viewCheckbox chckd msg txt =
    label [ class [ Style.CheckboxLabel ] ]
        [ input
            [ checked chckd
            , type_ "checkbox"
            , onClick msg
            ]
            []
        , text txt
        ]


viewChanges : List Change -> Html Msg
viewChanges changes =
    div
        [ class [ Style.Changes ]
        , onMouseEnter Pause
        , onMouseLeave Play
        ]
        (List.map viewChange changes)


viewChange : Change -> Html Msg
viewChange change =
    div [ class [ Style.Change ] ]
        (juxt
            [ viewUserDot
            , viewSiteCode
            , viewLink
            , viewDiff
            ]
            change
        )


viewUserDot : Change -> Html Msg
viewUserDot change =
    let
        (User userName userType) =
            change.user

        className =
            case userType of
                Anonymous ->
                    Style.Red

                Human ->
                    Style.Blue

                Bot ->
                    Style.Black
    in
        a
            [ class [ className ]
            , title userName
            , href (getUserUrl change)
            , Html.Attributes.property "innerHTML" (Json.Encode.string "&#8226;")
            ]
            []


getUserUrl : Change -> String
getUserUrl { user, serverUrl } =
    let
        (User userName userType) =
            user
    in
        case userType of
            Anonymous ->
                serverUrl ++ "/wiki/Special:Contributions/" ++ userName

            _ ->
                serverUrl ++ "/wiki/User:" ++ userName


viewSiteCode : Change -> Html msg
viewSiteCode { wiki, serverName } =
    let
        code =
            case wiki of
                "wikidatawiki" ->
                    "wd"

                "commonswiki" ->
                    "cm"

                "metawiki" ->
                    "me"

                _ ->
                    String.slice 0 2 wiki
    in
        div [ class [ Style.SiteCode ], title serverName ]
            [ text ("[" ++ code ++ "]") ]


viewLink : Change -> Html msg
viewLink { url, comment, changeTitle } =
    a
        [ href url
        , class [ Style.Title ]
        , title comment
        ]
        [ text changeTitle ]


viewDiff : Change -> Html msg
viewDiff { length } =
    case length of
        Just { new, old } ->
            let
                ( positive, size ) =
                    case old of
                        Just old_ ->
                            ( old_ < new
                            , abs (old_ - new)
                            )

                        Nothing ->
                            ( True, new )

                prefix =
                    if positive then
                        "+"
                    else
                        "-"

                className =
                    if positive then
                        Style.Green
                    else
                        Style.Red
            in
                div [ class [ Style.Diff, className ] ]
                    [ text (prefix ++ (toString size)) ]

        Nothing ->
            text ""

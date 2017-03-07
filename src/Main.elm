port module Lunchtime exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (title)
import Html.CssHelpers
import Json.Decode exposing (bool, int, string, nullable, succeed, fail)
import Json.Decode.Pipeline exposing (decode, required, resolve)
import Json.Encode
import Result exposing (Result(Ok, Err))
import Regex
import Style


{ class } =
    Html.CssHelpers.withNamespace Style.namespace


type alias Model =
    { changes : List Change
    }


type Msg
    = NewChange Change
    | NoOp


type alias Change =
    { id : Maybe Int
    , changeType : Result String ChangeType
    , user : User
    , wiki : String
    , serverName : String
    }


type UserType
    = Anonymous
    | Human
    | Bot


type User
    = User UserName UserType


type alias UserName =
    String


type ChangeType
    = Edit
    | New
    | Log
    | Categorize


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd msg )
init =
    ( Model [], Cmd.none )


view : Model -> Html Msg
view model =
    div [ class [ Style.Wrapper ] ]
        [ div [ class [ Style.Changes ] ] (List.map viewChange model.changes)
        ]


viewChange : Change -> Html Msg
viewChange change =
    div [ class [ Style.Change ] ]
        [ userDot change.user
        , siteCode change.wiki change.serverName
        ]


userDot : User -> Html Msg
userDot (User userName userType) =
    let
        className =
            case userType of
                Anonymous ->
                    Style.Red

                Human ->
                    Style.Blue

                Bot ->
                    Style.Black
    in
        div
            [ class [ className ]
            , title userName
            , Html.Attributes.property "innerHTML" (Json.Encode.string "&#8226;")
            ]
            []


siteCode : String -> String -> Html msg
siteCode wiki serverName =
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


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NewChange change ->
            ( { model
                | changes =
                    model.changes
                        |> (::) change
                        |> List.take 12
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    changes decodeChange


decodeChange : String -> Msg
decodeChange json =
    let
        value =
            Json.Decode.decodeString changeDecoder json
    in
        case value of
            Ok change ->
                NewChange change

            _ ->
                NoOp


changeDecoder : Json.Decode.Decoder Change
changeDecoder =
    let
        computeUser : String -> Bool -> User
        computeUser userName isBot =
            let
                isAnonymous =
                    Regex.contains
                        (Regex.regex "^\\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}$")
                        userName
            in
                if isBot then
                    User userName Bot
                else if isAnonymous then
                    User userName Anonymous
                else
                    User userName Human

        computeChangeType : String -> Result String ChangeType
        computeChangeType changeType =
            case changeType of
                "edit" ->
                    Ok Edit

                "new" ->
                    Ok New

                "categorize" ->
                    Ok Categorize

                "log" ->
                    Ok Log

                _ ->
                    Err ("No such change type: " ++ changeType)

        toChange :
            Maybe Int
            -> String
            -> String
            -> Bool
            -> String
            -> String
            -> Json.Decode.Decoder Change
        toChange id changeType userName bot wiki serverName =
            succeed
                (Change
                    id
                    (computeChangeType changeType)
                    (computeUser userName bot)
                    wiki
                    serverName
                )
    in
        decode toChange
            |> required "id" (nullable int)
            |> required "type" string
            |> required "user" string
            |> required "bot" bool
            |> required "wiki" string
            |> required "server_name" string
            |> resolve


changeTypeDecoder : Json.Decode.Decoder ChangeType
changeTypeDecoder =
    let
        decodeChangeType changeType =
            case changeType of
                "edit" ->
                    succeed Edit

                "new" ->
                    succeed New

                "categorize" ->
                    succeed Categorize

                "log" ->
                    succeed Log

                _ ->
                    fail ("Not a valid change type: " ++ changeType)
    in
        Json.Decode.andThen decodeChangeType string


port changes : (String -> msg) -> Sub msg

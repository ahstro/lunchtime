port module Lunchtime exposing (..)

import Html exposing (Html, div, text)
import Html.CssHelpers
import Json.Decode exposing (bool, int, string, nullable, succeed, fail)
import Json.Decode.Pipeline exposing (decode, required, resolve)
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
    div [] [ text (toString change) ]


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
            -> Json.Decode.Decoder Change
        toChange id changeType userName bot =
            succeed
                (Change
                    id
                    (computeChangeType changeType)
                    (computeUser userName bot)
                )
    in
        decode toChange
            |> required "id" (nullable int)
            |> required "type" string
            |> required "user" string
            |> required "bot" bool
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

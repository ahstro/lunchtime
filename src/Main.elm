port module Lunchtime exposing (..)

import Html exposing (Html, text)
import Json.Decode exposing (bool, int, string, nullable, succeed, fail)
import Json.Decode.Pipeline exposing (decode, required, resolve)
import Result exposing (Result(Ok, Err))
import Regex


type alias Model =
    String


type Msg
    = NewChange Change
    | NoOp


type alias Change =
    { id : Maybe Int
    , changeType : Result String ChangeType
    , user : User
    }


type User
    = Anonymous UserName
    | Human UserName
    | Bot UserName


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
    ( "foobar", Cmd.none )


view : Model -> Html msg
view model =
    text model


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NewChange change ->
            ( toString change, Cmd.none )

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
                    (getChangeType changeType)
                    (getUser userName bot)
                )
    in
        decode toChange
            |> required "id" (nullable int)
            |> required "type" string
            |> required "user" string
            |> required "bot" bool
            |> resolve


getUser : String -> Bool -> User
getUser userName isBot =
    let
        isAnonymous =
            Regex.contains
                (Regex.regex "^\\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}$")
                userName
    in
        if isBot then
            Bot userName
        else if isAnonymous then
            Anonymous userName
        else
            Human userName


getChangeType changeType =
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

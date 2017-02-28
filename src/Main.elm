port module Lunchtime exposing (..)

import Html exposing (Html, text)
import Json.Decode exposing (int, string, nullable, succeed, fail)
import Json.Decode.Pipeline exposing (decode, required)
import Result exposing (Result(Ok, Err))


type alias Model =
    String


type Msg
    = NewChange Change
    | NoOp


type alias Change =
    { id : Maybe Int
    , changeType : ChangeType
    }


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
    decode Change
        |> required "id" (nullable int)
        |> required "type" changeTypeDecoder


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

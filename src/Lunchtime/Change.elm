module Lunchtime.Change
    exposing
        ( Change
        , ChangeType(..)
        , changeDecoder
        )

import Json.Decode exposing (bool, int, string, nullable, succeed, fail)
import Json.Decode.Pipeline exposing (decode, required, resolve)
import Regex
import Lunchtime.User exposing (User(..), UserType(..))


type alias Change =
    { id : Maybe Int
    , changeType : Result String ChangeType
    , user : User
    , wiki : String
    , serverName : String
    , serverUrl : String
    , changeTitle : String
    , comment : String
    , url : String
    , revision : Maybe Revision
    , length : Maybe Length
    }


type ChangeType
    = Edit
    | New
    | Log
    | Categorize


type alias Length =
    { new : Int
    , old : Maybe Int
    }


type alias Revision =
    { new : Int
    , old : Int
    }


changeDecoder : Json.Decode.Decoder Change
changeDecoder =
    decode toChange
        |> required "id" (nullable int)
        |> required "type" string
        |> required "user" string
        |> required "bot" bool
        |> required "wiki" string
        |> required "server_name" string
        |> required "title" string
        |> required "comment" string
        |> required "server_url" string
        |> required "server_script_path" string
        |> required "revision" (nullable revisionDecoder)
        |> required "length" (nullable lengthDecoder)
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


revisionDecoder : Json.Decode.Decoder Revision
revisionDecoder =
    decode Revision
        |> required "new" int
        |> required "old" int


lengthDecoder : Json.Decode.Decoder Length
lengthDecoder =
    decode Length
        |> required "new" int
        |> required "old" (nullable int)


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


computeUrl : Result String ChangeType -> String -> String -> Maybe Revision -> String
computeUrl changeType serverUrl serverScriptPath revision =
    let
        computedUrl =
            case revision of
                Just { new } ->
                    serverUrl ++ serverScriptPath ++ "/index.php?diff=" ++ (toString new)

                Nothing ->
                    serverUrl
    in
        case changeType of
            Ok Edit ->
                computedUrl

            Ok New ->
                computedUrl

            _ ->
                serverUrl


toChange :
    Maybe Int
    -> String
    -> String
    -> Bool
    -> String
    -> String
    -> String
    -> String
    -> String
    -> String
    -> Maybe Revision
    -> Maybe Length
    -> Json.Decode.Decoder Change
toChange id changeType userName bot wiki serverName changeTitle comment serverUrl serverScriptPath revision length =
    let
        computedChangeType =
            (computeChangeType changeType)
    in
        succeed
            (Change
                id
                computedChangeType
                (computeUser userName bot)
                wiki
                serverName
                serverUrl
                changeTitle
                comment
                (computeUrl
                    computedChangeType
                    serverUrl
                    serverScriptPath
                    revision
                )
                revision
                length
            )

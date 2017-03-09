port module Lunchtime exposing (..)

import Html exposing (Html, div, text, a)
import Html.Attributes exposing (title, href)
import Html.Events exposing (onMouseEnter, onMouseLeave)
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
    , bufferedChanges : List Change
    , paused : Bool
    }


type Msg
    = NewChange Change
    | Play
    | Pause
    | NoOp


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


type alias Revision =
    { new : Int
    , old : Int
    }


type alias Length =
    { new : Int
    , old : Maybe Int
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
    ( Model [] [] False, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class [ Style.Wrapper ] ]
        [ div
            [ class [ Style.Changes ]
            , onMouseEnter Pause
            , onMouseLeave Play
            ]
            (List.map viewChange model.changes)
        ]


viewChange : Change -> Html Msg
viewChange change =
    div [ class [ Style.Change ] ]
        (juxt
            [ userDot
            , siteCode
            , link
            , diff
            ]
            change
        )


juxt : List (a -> b) -> a -> List b
juxt fs a =
    List.map (\f -> f a) fs


userDot : Change -> Html Msg
userDot change =
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


siteCode : Change -> Html msg
siteCode { wiki, serverName } =
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


link : Change -> Html msg
link { url, comment, changeTitle } =
    a
        [ href url
        , class [ Style.Title ]
        , title comment
        ]
        [ text changeTitle ]


diff : Change -> Html msg
diff { length } =
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


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NewChange change ->
            case model.paused of
                True ->
                    ( { model
                        | bufferedChanges =
                            change :: model.bufferedChanges
                      }
                    , Cmd.none
                    )

                False ->
                    ( { model
                        | changes =
                            model.changes
                                |> (::) change
                                |> takeMaxChanges
                      }
                    , Cmd.none
                    )

        Play ->
            ( { model
                | paused = False
                , changes =
                    model.bufferedChanges
                        |> (++) model.changes
                        |> takeMaxChanges
                , bufferedChanges = []
              }
            , Cmd.none
            )

        Pause ->
            ( { model | paused = True }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


takeMaxChanges : List a -> List a
takeMaxChanges =
    List.take 1024


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
    in
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


port changes : (String -> msg) -> Sub msg

module Lunchtime.Update
    exposing
        ( Msg(..)
        , update
        )

import Lunchtime.Model exposing (Model, Settings)
import Lunchtime.Change exposing (Change, ChangeType)
import Lunchtime.User exposing (User(..), UserType)


type Msg
    = ToggleChangeType ChangeType
    | ToggleUserType UserType
    | NewChange Change
    | Play
    | Pause
    | NoOp


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        ToggleChangeType changeType ->
            let
                { settings } =
                    model

                newChangeTypes =
                    toggle changeType settings.changeTypes

                newSettings =
                    { settings | changeTypes = newChangeTypes }
            in
                ( { model | settings = newSettings }, Cmd.none )

        ToggleUserType userType ->
            let
                { settings } =
                    model

                newUserTypes =
                    toggle userType settings.userTypes

                newSettings =
                    { settings | userTypes = newUserTypes }
            in
                ( { model | settings = newSettings }, Cmd.none )

        NewChange change ->
            if not (isLegalChange model.settings change) then
                update NoOp model
            else if model.paused then
                ( { model
                    | bufferedChanges =
                        model.bufferedChanges
                            |> (::) change
                            |> takeMaxChanges
                  }
                , Cmd.none
                )
            else
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


isLegalChange : Settings -> Change -> Bool
isLegalChange settings change =
    let
        legalChangeType =
            case change.changeType of
                Ok changeType ->
                    List.member changeType settings.changeTypes

                Err error ->
                    Debug.log error False

        legalUserType =
            case change.user of
                User _ userType ->
                    List.member userType settings.userTypes
    in
        legalChangeType && legalUserType


takeMaxChanges : List a -> List a
takeMaxChanges =
    List.take 128


toggle : a -> List a -> List a
toggle member list =
    if List.member member list then
        List.filter ((/=) member) list
    else
        member :: list

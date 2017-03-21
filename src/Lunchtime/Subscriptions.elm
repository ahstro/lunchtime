port module Lunchtime.Subscriptions exposing (subscriptions)

import Json.Decode
import Lunchtime.Model exposing (Model)
import Lunchtime.Update exposing (Msg(..))
import Lunchtime.Change


subscriptions : Model -> Sub Msg
subscriptions _ =
    changes decodeChange


decodeChange : String -> Msg
decodeChange json =
    let
        value =
            Json.Decode.decodeString Lunchtime.Change.changeDecoder json
    in
        case value of
            Ok change ->
                NewChange change

            _ ->
                NoOp


port changes : (String -> msg) -> Sub msg

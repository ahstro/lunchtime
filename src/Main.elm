module Lunchtime exposing (main)

import Html
import Lunchtime.View exposing (view)
import Lunchtime.Model exposing (Model, init)
import Lunchtime.Update exposing (update)
import Lunchtime.Subscriptions exposing (subscriptions)
import Lunchtime.Change exposing (Change, ChangeType(..))
import Lunchtime.Style as Style
import Lunchtime.User exposing (User(..), UserType(..))


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

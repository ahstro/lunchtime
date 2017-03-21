module Lunchtime.Model
    exposing
        ( Model
        , Settings
        , init
        )

import Lunchtime.Change exposing (Change, ChangeType(..))
import Lunchtime.User exposing (UserType(..))


type alias Model =
    { changes : List Change
    , bufferedChanges : List Change
    , paused : Bool
    , settings : Settings
    }


type alias Settings =
    { changeTypes : List ChangeType
    , userTypes : List UserType
    }


init : ( Model, Cmd msg )
init =
    ( { changes = []
      , bufferedChanges = []
      , paused = False
      , settings =
            { changeTypes = [ Edit, New, Log, Categorize ]
            , userTypes = [ Anonymous, Human, Bot ]
            }
      }
    , Cmd.none
    )

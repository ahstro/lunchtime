module Helpers exposing (juxt)

{-|
## Lists
@docs juxt
-}


{-| Takes a list of functions and an argument they all take as input
and returns a list of the results of each function call

    juxt [ toUpper, toLower ] "AHStro" == [ "AHSTRO", "ahstro" ]
-}
juxt : List (a -> b) -> a -> List b
juxt fs a =
    List.map (\f -> f a) fs

module Lunchtime.User
    exposing
        ( User(..)
        , UserType(..)
        )


type UserType
    = Anonymous
    | Human
    | Bot


type User
    = User UserName UserType


type alias UserName =
    String

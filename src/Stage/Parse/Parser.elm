module Stage.Parse.Parser exposing (module_)

import AST.Frontend as Frontend
import Common
import Common.Types
    exposing
        ( FilePath
        , Module
        , ModuleName
        , ModuleType(..)
        )
import Error
    exposing
        ( Error(..)
        , ParseContext(..)
        , ParseError(..)
        , ParseProblem(..)
        )
import Parser.Advanced as P exposing ((|.), (|=), Parser)


type alias Parser_ a =
    Parser ParseContext ParseProblem a


module_ : FilePath -> Parser_ (Module Frontend.Expr)
module_ filePath =
    P.oneOf
        [ plainModule filePath
        , portModule filePath
        , effectModule filePath
        ]


plainModule : FilePath -> Parser_ (Module Frontend.Expr)
plainModule filePath =
    generalModule PlainModule filePath


{-| Example: port module Foo exposing (bar)
-}
portModule : FilePath -> Parser_ (Module Frontend.Expr)
portModule filePath =
    P.succeed identity
        |. P.keyword (P.Token "port" ExpectingPortKeyword)
        |. spacesOnly
        -- TODO or is there a newline allowed between the words `port` and `module`?
        |= generalModule PortModule filePath


effectModule : FilePath -> Parser_ (Module Frontend.Expr)
effectModule filePath =
    Debug.todo "effectModule"


generalModule : ModuleType -> FilePath -> Parser_ (Module Frontend.Expr)
generalModule moduleType filePath =
    Debug.todo "generalModule"


spacesOnly : Parser_ ()
spacesOnly =
    P.chompWhile ((==) ' ')

module Error exposing
    ( DesugarError(..)
    , EmitError(..)
    , Error(..)
    , ErrorCode(..)
    , GeneralError(..)
    , OptimizeError(..)
    , ParseContext(..)
    , ParseError(..)
    , ParseProblem(..)
    , PrepareForBackendError(..)
    , TypeError(..)
    , parseErrorCode
    , toString
    )

import Common.Types
    exposing
        ( FilePath(..)
        , ModuleName(..)
        , VarName(..)
        )
import Json.Decode as JD
import Parser.Advanced as P


type Error
    = GeneralError GeneralError
    | ParseError ParseError
    | DesugarError DesugarError
    | TypeError TypeError
    | OptimizeError OptimizeError
    | PrepareForBackendError PrepareForBackendError
    | EmitError EmitError


type GeneralError
    = FileNotInSourceDirectories FilePath
    | IOError ErrorCode


type ParseError
    = ModuleNameDoesntMatchFilePath ModuleName FilePath
    | FileNotFound FilePath
    | EmptySourceDirectories
    | InvalidElmJson JD.Error
    | ParseProblem (List (P.DeadEnd ParseContext ParseProblem))


{-| TODO
-}
type ParseContext
    = TodoContextCases


type ParseProblem
    = ExpectingPortKeyword -- `>port< module ...`
    | ExpectingEffectKeyword -- `>effect< module ...`
    | ExpectingModuleKeyword -- `>module< Foo.Bar exposing (..)`
    | ExpectingModuleName -- `module >Foo.Bar< exposing (..)`
    | ExpectingExposingKeyword -- `module Foo.Bar >exposing< (..)`
    | ExpectingExposingAllSymbol -- `module Foo.Bar exposing >(..)<`
    | ExpectingExposingListLeftParen -- `module Foo.Bar exposing >(<a, b, c)`
    | ExpectingExposingListRightParen -- `module Foo.Bar exposing (a, b, c>)<`
    | ExpectingExposingListSeparatorComma -- `module Foo.Bar exposing (a>,< b, c)`
    | ExpectingExposedTypeDoublePeriod -- `module Foo.Bar exposing (Foo>(..)<)`
    | ExpectingVarName -- eg. `module Foo.Bar exposing (>a<)`
    | ExpectingTypeOrConstructorName -- eg. `module Foo.Bar exposing (>Foo<)`
    | ExposingListCantBeEmpty -- `module Foo.Bar exposing >()<`
    | ExpectingImportKeyword -- `>import< Foo as F exposing (..)`
    | ExpectingAsKeyword -- `import Foo >as< F exposing (..)`
    | ExpectingModuleNameWithoutDots -- `import Foo as >F< exposing (..)`
    | ExpectingEqualsSign -- `x >=< 1`
    | ExpectingMinusSign -- `>-<42`
    | ExpectingInt
    | ExpectingNewline
    | ExpectingEnd
    | ExpectingPlusOperator
    | InvalidInt
    | TodoNotImplemented


{-| TODO
-}
type DesugarError
    = VarNotInEnvOfModule VarName ModuleName


{-| TODO
-}
type TypeError
    = TodoFirstTypeError


{-| TODO
-}
type OptimizeError
    = TodoFirstOptimizeError


type PrepareForBackendError
    = MainDeclarationNotFound


{-| TODO
-}
type EmitError
    = TodoFirstEmitError


toString : Error -> String
toString error =
    case error of
        GeneralError generalError ->
            case generalError of
                FileNotInSourceDirectories (FilePath filePath) ->
                    "File `"
                        ++ filePath
                        ++ "` is not a part of the `sourceDirectories` in elm.json."

                IOError errorCode ->
                    case errorCode of
                        FileOrDirectoryNotFound (FilePath filePath) ->
                            "File or directory `" ++ filePath ++ "` not found."

                        OtherErrorCode other ->
                            "Encountered error `" ++ other ++ "`."

        ParseError parseError ->
            case parseError of
                ModuleNameDoesntMatchFilePath (ModuleName moduleName) (FilePath filePath) ->
                    "Module name `"
                        ++ moduleName
                        ++ "` doesn't match the file path `"
                        ++ filePath
                        ++ "`."

                FileNotFound (FilePath filePath) ->
                    "File `"
                        ++ filePath
                        ++ "` not found."

                EmptySourceDirectories ->
                    "Empty `sourceDirectories`!"

                InvalidElmJson jsonError ->
                    "Invalid elm.json! "
                        ++ JD.errorToString jsonError

                ParseProblem problems ->
                    "Parse problems: "
                        ++ Debug.toString problems

        DesugarError desugarError ->
            case desugarError of
                VarNotInEnvOfModule (VarName varName) (ModuleName moduleName) ->
                    "Can't find the variable `" ++ varName ++ "` in the module `" ++ moduleName ++ "`."

        TypeError typeError ->
            Debug.todo "toString typeError"

        OptimizeError optimizeError ->
            Debug.todo "toString optimizeError"

        PrepareForBackendError prepareForBackendError ->
            case prepareForBackendError of
                MainDeclarationNotFound ->
                    "Couldn't find the value `main` in the main module given to the compiler!"

        EmitError emitError ->
            Debug.todo "toString emitBackendError"


parseErrorCode : String -> FilePath -> ErrorCode
parseErrorCode code filePath =
    case code of
        "ENOENT" ->
            FileOrDirectoryNotFound filePath

        _ ->
            OtherErrorCode code


type ErrorCode
    = FileOrDirectoryNotFound FilePath
    | OtherErrorCode String

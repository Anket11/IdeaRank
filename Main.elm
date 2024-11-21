port module Main exposing (Model(..), Msg(..), init, main, mapTEA, subscriptions, switchSubAppsIfNeeded, update, view)


import Browser
import Html exposing (Html, a, button, div, img, nav, p, text)
import Html.Attributes exposing (alt, attribute, class, href, src, style, target)
import Html.Events exposing (onClick)
import File exposing (File)
import File.Download as Download
import File.Select as Select
import Json.Decode as Decode
import Json.Encode as Encode
import Task

import IdeaFight.Compete as Compete
import IdeaFight.LandingPage as LandingPage

-- MODEL
type Model
    = LandingPageModel LandingPage.Model
    | CompeteModel (Compete.Model String)
    | LoadOldState Model


-- MESSAGE
type Msg
    = LandingPageMsg LandingPage.Msg
    | CompeteMsg (Compete.Msg String)
    | PerformImportMsg
    | PerformExportMsg
    | FileSelectedForImportMsg File
    | FileLoadedMsg String
    | LoadOldModelMsg
    | IgnoreOldModelMsg


-- TRANSFORMATION UTILITY
mapTEA : (modela -> modelb) -> (msga -> msgb) -> ( modela, Cmd msga ) -> ( modelb, Cmd msgb )
mapTEA modelTransform msgTransform ( oldModel, oldCmd ) =
    ( modelTransform oldModel, Cmd.map msgTransform oldCmd )


-- INITIALIZATION
init : Maybe String -> ( Model, Cmd Msg )
init previousSessionState =
    case previousSessionState of
        Nothing ->
            mapTEA LandingPageModel LandingPageMsg <| LandingPage.init

        Just serializedState ->
            case decodeModel serializedState of
                Ok state ->
                    (LoadOldState state, Cmd.none)

                Err _ ->
                    mapTEA LandingPageModel LandingPageMsg <| LandingPage.init -- XXX inform the user?


-- DECODERS AND ENCODERS
ifType : String -> Decode.Decoder a -> Decode.Decoder a
ifType expectedType successDecoder =
    Decode.field "__type__" Decode.string
        |> Decode.andThen (\gotType -> if gotType == expectedType then successDecoder else Decode.fail "type didn't match")


decodeLandingPageModel : Decode.Decoder Model
decodeLandingPageModel =
    ifType "landing_page" LandingPage.decodeModel
        |> Decode.map LandingPageModel


decodeCompeteModel : Decode.Decoder Model
decodeCompeteModel =
    ifType "compete" Compete.decodeModel
        |> Decode.map CompeteModel


decodeModel : String -> Result Decode.Error Model
decodeModel =
    Decode.decodeString <| Decode.oneOf [ decodeLandingPageModel, decodeCompeteModel ]


encodeModel : Model -> Encode.Value
encodeModel model =
    case model of
        LandingPageModel landing_model ->
            Encode.object
                <| ("__type__", Encode.string "landing_page")
                :: LandingPage.encodeModel landing_model

        CompeteModel compete_model ->
            Encode.object
                <| ("__type__", Encode.string "compete")
                :: Compete.encodeModel compete_model

        LoadOldState innerModel ->
            encodeModel innerModel


-- SWITCH APPLICATIONS
switchSubAppsIfNeeded : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
switchSubAppsIfNeeded ( model, cmd ) =
    case model of
        LandingPageModel ( contents, True ) ->
            mapTEA CompeteModel CompeteMsg <| Compete.init <| String.lines <| String.trim contents

        _ ->
            ( model, cmd )


-- UPDATE
update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
    case ( msg, model ) of
        ( LandingPageMsg landing_msg, LandingPageModel landing_model ) ->
            switchSubAppsIfNeeded <| mapTEA LandingPageModel LandingPageMsg <| LandingPage.update landing_msg landing_model

        ( CompeteMsg compete_msg, CompeteModel compete_model ) ->
            mapTEA CompeteModel CompeteMsg <| Compete.update compete_msg compete_model

        ( PerformImportMsg, _ ) ->
            ( model, Select.file ["text/json"] FileSelectedForImportMsg )

        ( PerformExportMsg, _ ) ->
            let serializedModel = Encode.encode 0 <| encodeModel model
                downloadCmd = Download.string "idea-fight.json" "application/json" serializedModel
            in
            ( model, downloadCmd )

        ( FileSelectedForImportMsg file, _ ) ->
            ( model, Task.perform FileLoadedMsg <| File.toString file )

        ( FileLoadedMsg content, _ ) ->
            case decodeModel content of
                Ok newModel ->
                    ( newModel, Cmd.none )

                Err err ->
                    ( model, Cmd.none ) -- XXX handle error properly

        ( LoadOldModelMsg, LoadOldState oldModel ) ->
            ( oldModel, Cmd.none )

        ( IgnoreOldModelMsg, _ ) ->
            init Nothing

        ( _, _ ) ->
            ( model, Cmd.none ) -- Should be impossible


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( newModel, newMsg ) = update_ msg model
        serializedModel = Encode.encode 0 <| encodeModel newModel
        saveMsg = saveState serializedModel
    in
    ( newModel, Cmd.batch [ newMsg, saveMsg ] )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        LandingPageModel landing_model ->
            Sub.map LandingPageMsg <| LandingPage.subscriptions landing_model

        CompeteModel compete_model ->
            Sub.map CompeteMsg <| Compete.subscriptions compete_model

        LoadOldState _ ->
            Sub.none


-- VIEW
view : Model -> Html Msg
view model =
    let
        innerView =
            case model of
                LandingPageModel landing_model ->
                    Html.map LandingPageMsg <| LandingPage.view landing_model

                CompeteModel compete_model ->
                    Html.map CompeteMsg <| Compete.view Html.text Html.text compete_model

                LoadOldState _ ->
                    div []
                        [ p [] [ text "It seems you have returned after an unfinished session; would you like to restore the previous session's state?" ]
                        , button [ onClick LoadOldModelMsg, class "button-primary" ] [ text "Yes" ]
                        , button [ onClick IgnoreOldModelMsg, class "button-primary" ] [ text "No" ]
                        ]
    in
    div []
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "one-half column", style "margin-top" "25px" ]
                    [ innerView ]
                ]
            ]
        ]


-- PORT
port saveState : String -> Cmd msg


-- MAIN
main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

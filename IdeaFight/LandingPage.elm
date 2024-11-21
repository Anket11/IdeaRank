module IdeaFight.LandingPage exposing (Model, Msg, decodeModel, encodeModel, init, subscriptions, update, view)

import Html exposing (Html, a, br, button, div, form, h1, h4, hr, label, p, text, textarea)
import Html.Attributes exposing (class, for, name)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode

-- Model Definition
type alias Model =
    ( String, Bool )

type Msg
    = UpdateContents String
    | Continue

-- Initialization
init : ( Model, Cmd Msg )
init =
    ( ( "", False ), Cmd.none )

-- State Update
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateContents newContent ->
            ( ( newContent, False ), Cmd.none )

        Continue ->
            let
                ( contents, _ ) =
                    model
            in
            ( ( contents, True ), Cmd.none )

-- Subscriptions (None)
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

-- Render Description
descriptionParagraph : Html Msg
descriptionParagraph =
    p [ class "text-lg text-gray-600 mt-4 text-center" ]
        [ text "This is a web application for helping you decide the priorities of your ideas." ]

-- Render Input Form
inputForm : String -> Html Msg
inputForm contents =
    div [ class "mt-8 bg-white p-6 rounded-lg shadow-lg w-full" ]
        [ label [ for "idea-list", class "block text-lg font-semibold text-gray-700 mb-2" ]
            [ text "Enter one idea per line:" ]
        , textarea
            [ onInput UpdateContents
            , class "w-full h-40 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            , name "idea-list"
            ]
            [ text contents ]
        , button
            [ onClick Continue
            , class "mt-4 bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-lg shadow"
            ]
            [ text "Continue >" ]
        ]

-- Render Main View
view : Model -> Html Msg
view (contents, _) =
    div [ class "flex flex-col items-center min-h-screen bg-gray-50 py-12 w-screen" ]
        [ h1 [ class "text-4xl font-bold text-gray-800 mb-6 text-center w-full" ] [ text "Idea Rank!" ]
        , h4 [ class "text-2xl font-semibold text-gray-700 mb-4 text-center w-full" ] [ text "What's This?" ]
        , div [ class "w-full" ]
            [ descriptionParagraph ]
        , div [ class "w-full px-4" ]
            [ inputForm contents ]
        ]

-- JSON Decoding
decodeModel : Decode.Decoder Model
decodeModel =
    Decode.map2 Tuple.pair
        (Decode.field "content" Decode.string)
        (Decode.succeed False)

-- JSON Encoding
encodeModel : Model -> List ( String, Encode.Value )
encodeModel (contents, _) =
    [ ( "content", Encode.string contents ) ]

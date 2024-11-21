module IdeaFight.Compete exposing (Model, Msg, decodeModel, encodeModel, init, subscriptions, topValues, update, view)

import Browser.Events exposing (onKeyPress)
import Html exposing (Html, button, div, li, ol, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import IdeaFight.PartialForest as Forest
import IdeaFight.Shuffle as Shuffle
import Json.Decode as Decode
import Json.Encode as Encode
import Random


type Model idea
    = Uninitialized
    | Initialized (Forest.Forest idea)


type Msg idea
    = ShuffledContents (List idea)
    | Choice idea
    | NoOp


type alias Renderer idea =
    idea -> Html (Msg idea)


init : List idea -> ( Model idea, Cmd (Msg idea) )
init lines =
    ( Uninitialized, Random.generate ShuffledContents (Shuffle.shuffle lines) )


update : Msg idea -> Model idea -> ( Model idea, Cmd (Msg idea) )
update msg model =
    case (model, msg) of
        (Uninitialized, ShuffledContents contents) ->
            ( Initialized (Forest.fromList contents), Cmd.none )

        (Initialized forest, Choice choice) ->
            ( Initialized (Forest.choose forest choice), Cmd.none )

        _ ->
            ( model, Cmd.none )


decodeKeyPress : idea -> idea -> Decode.Decoder (Msg idea)
decodeKeyPress left right =
    Decode.map (keyToMsg left right) (Decode.field "key" Decode.string)


keyToMsg : idea -> idea -> String -> Msg idea
keyToMsg left right code =
    case code of
        "1" -> Choice left
        "2" -> Choice right
        _ -> NoOp


subscriptions : Model idea -> Sub (Msg idea)
subscriptions model =
    case model of
        Initialized forest ->
            case Forest.getNextPair forest of
                Just (left, right) ->
                    onKeyPress (decodeKeyPress left right)

                Nothing ->
                    Sub.none

        _ ->
            Sub.none


chooser : Renderer idea -> Forest.Forest idea -> Html (Msg idea)
chooser render forest =
    case Forest.getNextPair forest of
        Just (lhs, rhs) ->
            div [ class "flex flex-col items-center space-y-4 w-full" ]
                [ div [ class "text-lg font-extrabold text-gray-800 text-center w-full" ]
                    [ text "Which of these ideas do you like better?" ]
                , div [ class "flex justify-center space-x-6 w-full px-4" ]
                    [ button
                        [ onClick (Choice lhs)
                        , class "bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-6 text-md rounded-lg shadow-lg"
                        ]
                        [ render lhs ]
                    , button
                        [ onClick (Choice rhs)
                        , class "bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-6 text-md rounded-lg shadow-lg"
                        ]
                        [ render rhs ]
                    ]
                ]

        Nothing ->
            div [ class "flex flex-col items-center w-full text-gray-600 mt-4" ]
                [ text "Your ideas are totally ordered!" ]


topValuesSoFar : Renderer idea -> Forest.Forest idea -> Html (Msg idea)
topValuesSoFar render forest =
    let
        topIdeas = Forest.topN forest
    in
    div [ class "w-screen bg-white rounded-lg shadow-md mt-6 px-6 py-4" ]
        [ div [ class "text-md font-semibold text-gray-700 mb-4 w-screen" ]
            [ text "Your best ideas so far:" ]
        , ol [ class "list-decimal list-inside space-y-4" ]
            (List.map
                (\value ->
                    li [ class "p-3 bg-gray-100 rounded-md shadow-sm w-screen" ]
                        [ render value ]
                )
                topIdeas
            )
        ]


view : Renderer idea -> Renderer idea -> Model idea -> Html (Msg idea)
view renderChoice renderTopValue model =
    case model of
        Uninitialized ->
            div [ class "flex justify-center items-center w-screen bg-gray-50 text-gray-600 text-2xl" ]
                [ text "Loading..." ]

        Initialized forest ->
            div [ class "flex flex-col justify-between w-screen bg-gray-50" ]
                [ chooser renderChoice forest
                , topValuesSoFar renderTopValue forest
                ]


decodeModel : Decode.Decoder (Model String)
decodeModel =
    Decode.field "nodes" (Decode.map Initialized Forest.decodeJSON)


encodeModel : Model String -> List ( String, Encode.Value )
encodeModel model =
    case model of
        Uninitialized ->
            []

        Initialized forest ->
            [ ( "nodes", Forest.encodeJSON forest ) ]


topValues : Model idea -> List idea
topValues model =
    case model of
        Uninitialized ->
            []

        Initialized forest ->
            Forest.topN forest

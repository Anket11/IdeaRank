module IdeaFight.Compete exposing (Model, Msg, decodeModel, encodeModel, init, subscriptions, topValues, update, view)

import Browser.Events as Events
import Html exposing (Html, br, button, div, li, ol, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import IdeaFight.PartialForest as Forest
import IdeaFight.Shuffle as Shuffle
import Json.Decode as Decode
import Json.Encode as Encode
import Random


-- The Model defines the states of the application: Uninitialized or Initialized with a Forest.
type Model idea
    = Uninitialized
    | Initialized (Forest.Forest idea)


-- Msg defines user actions: receiving shuffled contents, making a choice, or no action.
type Msg idea
    = ShuffledContents (List idea)
    | Choice idea
    | NoOp


type alias Renderer idea =
    idea -> Html (Msg idea)


-- Initialize the application with a list of ideas. The shuffle process uses randomness.
init : List idea -> ( Model idea, Cmd (Msg idea) )
init lines =
    ( Uninitialized, Random.generate ShuffledContents <| Shuffle.shuffle lines )


-- Update handles state transitions based on user actions.
update : Msg idea -> Model idea -> ( Model idea, Cmd (Msg idea) )
update msg model =
    case model of
        Uninitialized ->
            case msg of
                ShuffledContents contents ->
                    ( Initialized <| Forest.fromList contents, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Initialized forest ->
            case msg of
                Choice choice ->
                    ( Initialized <| Forest.choose forest choice, Cmd.none )

                _ ->
                    ( model, Cmd.none )


-- Display a UI for comparing two ideas and selecting one.
chooser : Renderer idea -> Forest.Forest idea -> Html (Msg idea)
chooser render forest =
    case Forest.getNextPair forest of
        Just ( lhs, rhs ) ->
            div [ class "flex flex-col items-center space-y-4 w-full" ]
                [ div [ class "text-6xl font-extrabold text-gray-800 text-center w-full" ]
                    [ text "Which of these ideas do you like better?" ]
                , div [ class "flex justify-center space-x-6 w-full px-4" ]
                    [ button
                        [ onClick <| Choice lhs
                        , class "bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-6 text-4xl rounded-lg shadow-lg"
                        ]
                        [ render lhs ]
                    , button
                        [ onClick <| Choice rhs
                        , class "bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-6 text-4xl rounded-lg shadow-lg"
                        ]
                        [ render rhs ]
                    ]
                ]

        Nothing ->
            div [ class "flex flex-col items-center w-full text-gray-600 mt-4" ]
                [ text "Your ideas are totally ordered!" ]


-- Show the ranked ideas based on the user's choices.
topValuesSoFar : Renderer idea -> Forest.Forest idea -> Html (Msg idea)
topValuesSoFar render forest =
    let
        topIdeas =
            Forest.topN forest
    in
    case topIdeas of
        [] ->
            div [ class "text-gray-600 italic text-center text-lg w-screen px-4" ]
                [ text "We haven't found the best idea yet - keep choosing!" ]

        _ ->
            div [ class "w-screen bg-white rounded-lg shadow-md mt-6 px-6 py-4" ]
                [ div [ class "text-2xl font-semibold text-gray-700 mb-4 w-screen" ]
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


-- Generate the user interface by combining the chooser and the top values display.
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


-- Decode the Model from JSON, handling saved application state.
decodeModel : Decode.Decoder (Model String)
decodeModel =
    Decode.field "nodes" <| Decode.map Initialized Forest.decodeJSON


-- Encode the Model into JSON for saving the state.
encodeModel : Model String -> List ( String, Encode.Value )
encodeModel model =
    case model of
        Uninitialized ->
            []

        Initialized forest ->
            let
                encodedForest =
                    Forest.encodeJSON forest
            in
            [ ( "nodes", encodedForest ) ]


-- Decode user keypresses and map them to choices or no actions.
decodeKeyPress : idea -> idea -> Decode.Decoder (Msg idea)
decodeKeyPress left right =
    Decode.map (keyToMsg left right) <| Decode.field "key" Decode.string


keyToMsg : idea -> idea -> String -> Msg idea
keyToMsg left right code =
    if code == "1" then
        Choice left
    else if code == "2" then
        Choice right
    else
        NoOp


-- Subscriptions to listen for keypress events when comparisons are available.
subscriptions : Model idea -> Sub (Msg idea)
subscriptions model =
    case model of
        Uninitialized ->
            Sub.none

        Initialized forest ->
            case Forest.getNextPair forest of
                Just ( left, right ) ->
                    Events.onKeyPress <| decodeKeyPress left right

                Nothing ->
                    Sub.none
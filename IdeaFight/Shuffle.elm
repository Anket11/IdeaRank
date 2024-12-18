module IdeaFight.Shuffle exposing (shuffle)

import Random exposing (Generator)

extractValueHelper : a -> List a -> Int -> List a -> ( a, List a )
extractValueHelper first_value rest_values index accumulator =
    case (index, rest_values) of
        (0, _) ->
            (first_value, List.append (List.reverse accumulator) rest_values)

        (_, []) ->
            (first_value, List.reverse accumulator)

        (_, head :: tail) ->
            extractValueHelper head tail (index - 1) (first_value :: accumulator)


extractValue : a -> List a -> Int -> ( a, List a )
extractValue first_value rest_values index =
    extractValueHelper first_value rest_values index []


shuffle : List a -> Generator (List a)
shuffle values =
    case values of
        [] ->
            Random.constant []

        first_value :: rest_values ->
            let
                randomIndexGenerator =
                    Random.int 0 (List.length rest_values)

                buildShuffledList =
                    \index ->
                        let
                            (selectedElement, remainingElements) =
                                extractValue first_value rest_values index

                            shuffledTailGenerator =
                                shuffle remainingElements
                        in
                        Random.map (\shuffledTail -> selectedElement :: shuffledTail) shuffledTailGenerator
            in
            Random.andThen buildShuffledList randomIndexGenerator

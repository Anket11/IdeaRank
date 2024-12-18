module IdeaFight.PartialForest exposing (Forest, choose, decodeJSON, encodeJSON, fromList, getNextPair, topN)

import Json.Decode as Decode
import Json.Encode as Encode


type Node a
    = Node a (List (Node a))


type Forest a
    = Forest (List (Node a))


makeNode : a -> Node a
makeNode value =
    Node value []


fromList : List a -> Forest a
fromList values =
    Forest (List.map makeNode values)


getNextPairNodes : List (Node a) -> Maybe ( a, a )
getNextPairNodes nodes =
    case nodes of
        (Node a _) :: (Node b _) :: _ ->
            Just (a, b)

        [Node _ children] ->
            getNextPairNodes children

        _ ->
            Nothing


getNextPair : Forest a -> Maybe ( a, a )
getNextPair (Forest nodes) =
    getNextPairNodes nodes


reparentNode : Node a -> Node a -> Node a
reparentNode (Node parentValue children) child =
    Node parentValue (child :: children)


nodeValue : Node a -> a
nodeValue (Node value _) =
    value


chooseNodes : List (Node a) -> a -> List (Node a)
chooseNodes nodes choice =
    case nodes of
        firstNode :: secondNode :: rest ->
            if choice == nodeValue firstNode then
                rest ++ [reparentNode firstNode secondNode]

            else if choice == nodeValue secondNode then
                rest ++ [reparentNode secondNode firstNode]

            else
                rest ++ [reparentNode firstNode secondNode] -- Should never happen!

        [Node value children] ->
            [Node value (chooseNodes children choice)]

        _ ->
            nodes -- Should never happen!


choose : Forest a -> a -> Forest a
choose (Forest values) choice =
    Forest (chooseNodes values choice)


topNNodes : List (Node a) -> List a
topNNodes nodes =
    case nodes of
        [Node value children] ->
            value :: topNNodes children

        _ ->
            []


topN : Forest a -> List a
topN (Forest nodes) =
    topNNodes nodes


decodeValue : Decode.Decoder String
decodeValue =
    Decode.field "value" Decode.string


decodeChildren : Decode.Decoder (List (Node String))
decodeChildren =
    Decode.field "children" (Decode.list (Decode.lazy (\_ -> decodeNode)))


decodeNode : Decode.Decoder (Node String)
decodeNode =
    Decode.map2 Node decodeValue decodeChildren


decodeJSON : Decode.Decoder (Forest String)
decodeJSON =
    Decode.map Forest (Decode.list decodeNode)


encodeNode : Node String -> Encode.Value
encodeNode (Node value children) =
    Encode.object
        [ ("value", Encode.string value)
        , ("children", Encode.list encodeNode children)
        ]


encodeJSON : Forest String -> Encode.Value
encodeJSON (Forest nodes) =
    Encode.list encodeNode nodes

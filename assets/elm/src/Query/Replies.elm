module Query.Replies exposing (Response, request)

import Connection exposing (Connection)
import GraphQL exposing (Document)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Reply exposing (Reply)
import Session exposing (Session)
import Task exposing (Task)


type alias Response =
    { replies : Connection Reply
    }


document : Document
document =
    GraphQL.toDocument
        """
        query PostInit(
          $spaceId: ID!
          $postId: ID!
          $before: Cursor!
          $limit: Int!
        ) {
          space(id: $spaceId) {
            post(id: $postId) {
              replies(last: $limit, before: $before) {
                ...ReplyConnectionFields
              }
            }
          }
        }
        """
        [ Connection.fragment "ReplyConnection" Reply.fragment
        ]


variables : String -> String -> String -> Int -> Maybe Encode.Value
variables spaceId postId before limit =
    Just <|
        Encode.object
            [ ( "spaceId", Encode.string spaceId )
            , ( "postId", Encode.string postId )
            , ( "before", Encode.string before )
            , ( "limit", Encode.int limit )
            ]


decoder : Decoder Response
decoder =
    Decode.at [ "data", "space", "post", "replies" ] <|
        Decode.map Response (Connection.decoder Reply.decoder)


request : String -> String -> String -> Int -> Session -> Task Session.Error ( Session, Response )
request spaceId postId before limit session =
    Session.request session <|
        GraphQL.request document (variables spaceId postId before limit) decoder

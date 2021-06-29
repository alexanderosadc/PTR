-module(database).

-behaviour(gen_server).
-export([send_message/1, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link({local, database}, ?MODULE, [], []).

init([]) ->
    ets:new(tweet, [set, named_table]),
    ets:new(user, [set, named_table]),
    {ok, []}.

send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).

handle_cast({send_message, ListOfMaps}, State) ->
     % io:format("~p~p ~n", ["Database =", ListOfMaps]),
    ListOfTuples = lists:map(
        fun (Map) -> 
            separate_user(Map)
        end, ListOfMaps),
    % add_to_database(ListOfTuples),
    % Infomration = ets:info(tweet),
    % Size = lists:keyfind(size, 1, Infomration),
    % Infomration1 = ets:info(user),
    % Size1 = lists:keyfind(size, 1, Infomration1),
    % io:format("~p~p ~n", ["Database Tweets =", Size]),
    % io:format("~p~p ~n", ["Database Users =", Size1]),
    {noreply, State}.

add_to_database([Head | Tail]) ->
    {TweetId, TweetMap, UserMap, Sentiment, Engagement} = Head,
    Tweet = {TweetId, TweetMap, Sentiment, Engagement},
    User = {UserMap},
    % io:format("~p~p ~n", ["Database =", UserMap]),
    % io:format("~p~p ~n", ["Database =", TweetMap]),

    ets:insert(tweet, Tweet),
    ets:insert(user, User),
    add_to_database(Tail);
add_to_database([]) ->
    ok.

separate_user(Map) ->
    #{
        <<"Twitter_ID">> := TweetId,
        <<"Tweet">> := 
            #{
                <<"message">> := 
                #{
                    <<"tweet">> := Tweet
                }
            },
        <<"Sentiment">> := Sentiment,
        <<"Engagement">> := Engagement
    } = Map,
    #{
        <<"user">> := UserMap
    } = Tweet,
    %  io:format("~p ~n", [UserMap]),
    % DecodedJson = jsx:decode(Tweet),
    SentimentMap = #{<<"sentiment_score">> => float(Sentiment)},
    EngagementMap = #{<<"engagement_score">> => float(Engagement)},
    tcp_client:send_message("msg_publisher", "sentiment", SentimentMap),
    tcp_client:send_message("msg_publisher", "engagement", EngagementMap),
    tcp_client:send_message("msg_publisher", "tweet", UserMap),
    TweetMap = maps:without([<<"user">>], Tweet),
    {TweetId, TweetMap, UserMap, Sentiment, Engagement}.
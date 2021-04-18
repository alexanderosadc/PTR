-module(agregator).
-behaviour(gen_server).
-export([send_message/1, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link({local, agregator}, ?MODULE, [], []).

init([]) ->
    {ok, []}.

send_message(Message) ->
    % io:format("~p~p ~n", ["EventData =", Message]),
    gen_server:cast(?MODULE, {send_message, Message}).


handle_cast({send_message, SentMap}, ListOfMaps) when length(ListOfMaps) > 0 ->
    % io:format("~p~p ~n", ["EventData =", EventData]),
    ListOfUpdatedMaps = lists:map(
        fun(MapFromList) ->
            match_tweet(MapFromList, SentMap)
        end,
    ListOfMaps),
    {noreply, ListOfUpdatedMaps};

handle_cast({send_message, SentMap}, ListOfMaps) when length(ListOfMaps) =:= 0 ->
    % io:format("~p~p ~n", ["EventData =", EventData]),
    ListOfUpdatedMaps = [match_tweet(#{}, SentMap)],
    {noreply, ListOfUpdatedMaps}.

match_tweet(Map, SentMap) ->
    Twitter_ID = get_twitter_id(SentMap, true),
    IsMapExists = check_if_key_is_in_list(SentMap, Map),
    % io:format("~p~p ~n", ["MAP = ", IsMapExists]),
    NewMap = add_elements_to_map(SentMap, IsMapExists),
    
    FinalMap = maps:merge(Map, NewMap),
    io:format("~p~p ~n", ["MAP = ", FinalMap]),
    FinalMap.


check_if_key_is_in_list(SentMap, Map) ->
    Twitter_ID_Sent_Map = get_twitter_id(SentMap, true),
    Twitter_ID_Map = get_twitter_id(Map, maps:is_key(<<"Twitter_ID">>, Map)),
    Twitter_ID_Sent_Map =:= Twitter_ID_Map.

add_elements_to_map(SentMap, _) ->
    % #{
    %     <<"Twitter_ID">> => get_twitter_id(SentMap, true),
    %     <<"Engagement">> => get_engagement_from_map(SentMap, maps:is_key(<<"Engagement">>, SentMap)), 
    %     <<"Sentiment">> => get_sentiment_from_map(SentMap, maps:is_key(<<"Sentiment">>, SentMap)), 
    %     <<"Tweet">> => get_text_from_map(SentMap, maps:is_key(<<"Tweet">>, SentMap))
    % }.
    SentMap.

get_twitter_id(SentMap, true) ->
     #{<<"Twitter_ID">> := Twitter_ID} = SentMap,
     Twitter_ID;
get_twitter_id(SentMap, false) ->
    0.

get_sentiment_from_map(SentMap, true) ->
    #{<<"Sentiment">> := Sentiment} = SentMap,
    Sentiment;
get_sentiment_from_map(SentMap, false) ->
    0.

get_engagement_from_map(SentMap, true) ->
    #{<<"Engagement">> := Engagement} = SentMap,
    Engagement;
get_engagement_from_map(SentMap, false) ->
    0.

get_text_from_map(SentMap, true) ->
    #{<<"Tweet">> := Tweet} = SentMap,
    Tweet;
get_text_from_map(SentMap, false) ->
    ""
.

-module(sentinel_worker).
-behaviour(gen_server).
-export([send_message/2, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, {}}.

send_message(EventMessageBinary, Pid) ->
    gen_server:cast(Pid, {send_message, EventMessageBinary}).
    
handle_cast({send_message, EventMessageBinary}, State) ->
    % io:format("~p: ~p ~n", [self(), byte_size(EventMessageBinary)]),
    EventMap = shotgun:parse_event(EventMessageBinary),
    #{data := EventData} = EventMap,
    check_json(EventData, jsx:is_json(EventData)),
    % io:format("~p ~n", [EventData]),
    {noreply, State}.

check_json(Json, IsJson) when IsJson ->
    JsonMap = jsx:decode(Json),
    % io:format("~p ~n", [JsonMap]),
    #{<<"message">> := #{<<"tweet">> := #{<<"text">> := TweetText}}} = JsonMap,
    JsonToUnicode = unicode:characters_to_list(TweetText),
    TweetTokens = string:tokens(JsonToUnicode, "&#0123456789,./'\";:{}[]()*%/+-_<>!?\n@ "), 
    % io:format("~p ~n", [TweetTokens]);
    calculate_score(TweetTokens);

check_json(Json, IsJson) ->
    ok.

calculate_score(TweetTokens) ->
    ScoresInTweet =  lists:map(
        fun(Key) when is_integer(Key) =:= false ->
            LowerKey = string:to_lower(Key),
            Score = emotional_score:find_emotion(LowerKey),
            Score
        end, 
    TweetTokens),
    % io:format("~p ~n", [ScoresInTweet]),
    SumOfTweetTokens = lists:sum(ScoresInTweet),
    EmotionalScore = SumOfTweetTokens / length(ScoresInTweet),
    io:format("~p ~n", [EmotionalScore]),
    EmotionalScore.
    
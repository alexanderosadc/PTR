-module(engagement_ratio_worker).
-behaviour(gen_server).
-export([send_message/2, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, {}}.

send_message(EventMessageBinary, Pid) ->
    gen_server:cast(Pid, {send_message, EventMessageBinary}).
    
handle_cast({send_message, EventMessageBinary}, State) ->
    EventMap = shotgun:parse_event(EventMessageBinary),
    #{data := EventData} = EventMap,
    io:format("~p ~n", ["Huinea"]),
    check_json(EventData, jsx:is_json(EventData)),
    {noreply, State}.

check_json(Json, IsJson) when IsJson ->
    JsonMap = jsx:decode(Json),
    #{
        <<"retweet_count">> := NrOfRetweets,
        <<"favorite_count">> := NrOfFavourites,
        <<"user">> := #{<<"followers_count">> := NrOfFollowers}} = JsonMap,

    Engagement = (NrOfFavourites / NrOfRetweets) / NrOfFollowers,
    io:format("~p ~n", [Engagement]);

check_json(TweetText, _) ->
    PanicText = string:find(TweetText, "panic"),
    kill_process(PanicText),
    ok.

kill_process(PanicText) when  PanicText =:= nomatch->
   ok;

kill_process(PanicText) when PanicText /= nomatch ->
    exit(normal),
    ok.
    
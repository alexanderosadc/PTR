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
    check_json(EventData, jsx:is_json(EventData)),
    {noreply, State}.

check_retweeted_status(IsRetweetedStatus, JsonMap) when IsRetweetedStatus =:= true ->
    #{<<"message">> :=
        #{<<"tweet">> :=
            #{
                <<"retweeted_status">> := 
                    #{
                        <<"favorite_count">> := NrOfFavourites,
                        <<"retweet_count">> := NrOfRetweets,
                        
                        <<"user">> := #{
                            <<"followers_count">> := NrOfFollowers
                        }
                    }
            }
        }
    } = JsonMap,

    Engagement = (NrOfFavourites / NrOfRetweets);

check_retweeted_status(_, _) ->
    0.

check_json(Json, IsJson) when IsJson ->
    JsonMap = jsx:decode(Json),
     #{<<"message">> := #{<<"tweet">> := Tweet}} = JsonMap,
    IsRetweetedStatus = maps:is_key(<<"retweeted_status">>, Tweet),
    EngagementRatio = check_retweeted_status(IsRetweetedStatus, JsonMap),
    io:format("~p ~n", [EngagementRatio]);

check_json(TweetText, _) ->
    % io:format("~p ~n", ["Panic"]),
    PanicText = string:find(TweetText, "panic"),
    kill_process(PanicText),
    ok.

kill_process(PanicText) when  PanicText =:= nomatch->
   ok;

kill_process(PanicText) when PanicText /= nomatch ->
    exit(normal),
    ok.
    
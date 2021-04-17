-module(simple_worker).
-behaviour(gen_server).
-export([send_message/2, start_link/1, init/1 ,handle_cast/2]).

start_link(TypeOfPool) ->
    gen_server:start_link(?MODULE, TypeOfPool, []).

init([TypeOfPool]) ->
    {ok, TypeOfPool}.

send_message(EventMessageBinary, Pid) ->
    gen_server:cast(Pid, {send_message, EventMessageBinary}).
    
handle_cast({send_message, EventData}, TypeOfPool) ->
    check_json(EventData, TypeOfPool),
    {noreply, TypeOfPool}.

check_json(Json, sentiment) ->
    #{<<"JSON">> :=
        #{<<"message">> := 
            #{<<"tweet">> := 
                #{<<"text">> := TweetText}
            }
        },
    <<"Twitter_ID">> := TweetId
    } = Json,
    JsonToUnicode = unicode:characters_to_list(TweetText),
    TweetTokens = string:tokens(JsonToUnicode, "&#0123456789,./'\";:{}[]()*%/+-_<>!?\n@ "), 
    Score = calculate_score(TweetTokens),
    MapToSend = #{<<"Twitter_ID">> => TweetId, <<"Sentiment">> => Score},
    agregator:send_message(MapToSend);

check_json(Json, engagement) ->
    #{<<"JSON">> :=
        #{<<"message">> := 
            #{<<"tweet">> := Tweet}
        },
    <<"Twitter_ID">> := TweetId
    } = Json,
    IsRetweetedStatus = maps:is_key(<<"retweeted_status">>, Tweet),
    EngagementRatio = check_retweeted_status(IsRetweetedStatus, Json),
    MapToSend = #{<<"Twitter_ID">> => TweetId, <<"Engagement">> => EngagementRatio},
    agregator:send_message(MapToSend).

kill_process(PanicText) when  PanicText =:= nomatch->
   ok;

kill_process(PanicText) when PanicText /= nomatch ->
    exit(normal),
    ok.

check_retweeted_status(IsRetweetedStatus, JsonMap) when IsRetweetedStatus =:= true ->
    #{<<"JSON">> :=
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
    }} = JsonMap,

    (NrOfFavourites / NrOfRetweets) / NrOfFollowers;

check_retweeted_status(_, _) ->
    0.

calculate_score(TweetTokens) ->
    ScoresInTweet =  lists:map(
        fun(Key) when is_integer(Key) =:= false ->
            LowerKey = string:to_lower(Key),
            Score = emotional_score:find_emotion(LowerKey),
            Score
        end, 
    TweetTokens),
    SumOfTweetTokens = lists:sum(ScoresInTweet),
    EmotionalScore = SumOfTweetTokens / length(ScoresInTweet),
    % io:format("~p ~n", [EmotionalScore]),
    EmotionalScore.
    
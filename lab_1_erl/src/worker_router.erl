-module(worker_router).
-behaviour(gen_server).

-export([handle_call/3, handle_cast/2, init/1, start_link/0, send_message/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, {1, 1}}.

handle_call({_, _}, State, _)->
    {noreply, State}.

handle_cast({send_message, EventMessageBinary}, State) ->
    worker_scaler:new_message_appear(),
    
    SentimentChildrenPid = sentiment_worker_supervisor:get_all_children(),
    EngagementChildrenPid = engagement_worker_supervisor:get_all_children(),

    SentimentChildPidIndex = round_robin(EventMessageBinary, State, SentimentChildrenPid, sentiment),
    EngagementChildPidIndex = round_robin(EventMessageBinary, State, EngagementChildrenPid, engagement),
    {noreply, {SentimentChildPidIndex, EngagementChildPidIndex}}.
    
round_robin(EventMessageBinary, {SentimentIndex, _}, ListOfPids, sentiment) when SentimentIndex < length(ListOfPids) ->
    ChildrenPid = lists:nth(SentimentIndex, ListOfPids),
    sentiment_score_worker:send_message(EventMessageBinary, ChildrenPid),
    SentimentIndex + 1;

round_robin(EventMessageBinary,  {_, EngagementIndex}, ListOfPids, engagement) when EngagementIndex < length(ListOfPids) ->
    ChildrenPid = lists:nth(EngagementIndex, ListOfPids),
    % io:format("~p ~n", [EventMessageBinary]),
    engagement_ratio_worker:send_message(EventMessageBinary, ChildrenPid),
    EngagementIndex;

round_robin(_, N, ListOfPids, _) when N >= length(ListOfPids) ->
    1.

send_message(EventMessageBinary) ->
    gen_server:cast(?MODULE, {send_message, EventMessageBinary}).
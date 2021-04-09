-module(worker_router).
-behaviour(gen_server).

-export([handle_call/3, handle_cast/2, init/1, start_link/0, send_message/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, 1}.

handle_call({_, _}, State, _)->
    {noreply, State}.

handle_cast({send_message, EventMessageBinary}, State) ->
    worker_scaler:new_message_appear(),
    ChildrenPid = worker_supervisor:get_all_children(),
    ChildPidIndex = round_robin(EventMessageBinary, State, ChildrenPid),
    {noreply, ChildPidIndex}.

round_robin(EventMessageBinary, N, ListOfPids) when N < length(ListOfPids) ->
    ChildrenPid = lists:nth(N, ListOfPids),
    sentinel_worker:send_message(EventMessageBinary, ChildrenPid),
    N + 1;

round_robin(_, N, ListOfPids) when N >= length(ListOfPids) ->
    1.

send_message(EventMessageBinary) ->
    gen_server:cast(?MODULE, {send_message, EventMessageBinary}).
-module(worker_router).
-behaviour(gen_server).

-export([handle_call/3, handle_cast/2, init/1, start_link/1, send_message/2]).

start_link(TypeOfPool) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "router"),
    gen_server:start_link({local, AtomFromString}, ?MODULE, [TypeOfPool], []).

init([TypeOfPool]) ->
    {ok, {1, TypeOfPool}}.

handle_call({_, _}, State, _)->
    {noreply, State}.

handle_cast({send_message, EventMessageBinary}, {Index, TypeOfPool}) ->
    worker_scaler:new_message_appear(TypeOfPool),

    ChildrenPid = worker_supervisor:get_all_children(TypeOfPool),

    ChildPidIndex = round_robin(EventMessageBinary, Index, ChildrenPid),
    {noreply, {ChildPidIndex, TypeOfPool}}.
    
round_robin(EventMessageBinary, Index, ListOfPids) when Index < length(ListOfPids) ->
    ChildrenPid = lists:nth(Index, ListOfPids),
    simple_worker:send_message(EventMessageBinary, ChildrenPid),
    Index + 1;

round_robin(_, Index, ListOfPids) when Index >= length(ListOfPids) ->
    1.

send_message(TypeOfPool, EventMessageBinary) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "router"),
    gen_server:cast(AtomFromString, {send_message, EventMessageBinary}).
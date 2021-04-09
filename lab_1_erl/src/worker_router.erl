-module(worker_router).
-behaviour(gen_server).

-export([handle_call/3, handle_cast/2, init/1, start_link/0, send_message/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    % initialize_workers(4),
    {ok, 1}.

handle_call({_, _}, State, _)->
    {noreply, State}.

handle_cast({send_message, EventMessageBinary}, State) ->
    worker_scaler:new_message_appear(),
    ChildrenProcessData = worker_supervisor:get_all_children(),
    ChildrenPid = lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData),
    % io:format("~p: ~p ~n", [self(), ChildrenPid]),
    ChildPidIndex = round_robin(EventMessageBinary, State, ChildrenPid),
    % io:format("~p: ~p ~n", [self(), EventMessageBinary]),
    % sentinel_worker:send_message(EventMessageBinary),
    {noreply, ChildPidIndex}.

round_robin(EventMessageBinary, N, ListOfPids) ->
    ChildrenPid = lists:nth(N, ListOfPids),
    % io:format("~p~n", [ChildrenPid]),
    sentinel_worker:send_message(EventMessageBinary, ChildrenPid),
    indexReturning(N, ListOfPids).

indexReturning(N, ListOfPids) when N < length(ListOfPids) ->
    N + 1;
indexReturning(N, ListOfPids) when N >= length(ListOfPids) ->
    1.

initialize_workers(N) when N =< 0 -> 
    ok;
initialize_workers(N) when N > 0 ->
    worker_supervisor:add_new_child(),
    initialize_workers(N - 1).

% create_pid_children_array(ListOfPids, {_, ChildPid, _, _}, 0) ->
%     [ChildPid | ListOfPids ];
% create_pid_children_array(ListOfPids, , N) when N > 0 ->
%     create_pid_children_array([ChildPid | ListOfPids ], , N - 1).

send_message(EventMessageBinary) ->
    % sentinel_worker:send_message(EventMessageBinary).
    % io:format("~p: ~p ~n", [self(), byte_size(EventMessageBinary)]),
    gen_server:cast(?MODULE, {send_message, EventMessageBinary}).
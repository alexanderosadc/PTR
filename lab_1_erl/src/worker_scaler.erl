-module(worker_scaler).
-behaviour(gen_server).

-export([start_link/1, init/1, handle_cast/2, handle_info/2, new_message_appear/1]).

start_link(TypeOfPool) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "scaler"),
    gen_server:start_link({local, AtomFromString}, ?MODULE, [TypeOfPool], []).

init([TypeOfPool]) ->
    MessageCounter = 0,
    AtomFromString = useful_functions:get_atom(TypeOfPool, "scaler"),
    erlang:start_timer(0, AtomFromString, secondsexpired),
    {ok, {MessageCounter, TypeOfPool}}.

handle_cast(upscale, {MessageCounter, TypeOfPool}) ->
    {noreply, {MessageCounter + 1, TypeOfPool}}.

handle_info({_, _, secondsexpired}, {MessageCounter, TypeOfPool}) ->
    NrOfWorkersFuture = calculate_number_of_workers(MessageCounter),
    NrOfSentimentWorkersCurrent = length(worker_supervisor:get_all_children(TypeOfPool)),

    handle_number_of_workers(NrOfWorkersFuture, NrOfSentimentWorkersCurrent, TypeOfPool),
    erlang:start_timer(1000, self(), secondsexpired),
    {noreply, {0, TypeOfPool}}.

calculate_number_of_workers(MessageCounter) when MessageCounter < 100 ->
    1;
calculate_number_of_workers(MessageCounter) when MessageCounter >= 100 ->
    MessageCounter div 100.

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent, TypeOfPool) when NrOfWorkersCurrent  < (NrOfWorkersFuture + 3) ->
    worker_supervisor:add_new_child(TypeOfPool),
    handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent + 1, TypeOfPool);


handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent, TypeOfPool) when NrOfWorkersCurrent > (NrOfWorkersFuture + 3) ->
    worker_supervisor:remove_one_child(TypeOfPool);

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent, TypeOfPool) when NrOfWorkersCurrent =:= (NrOfWorkersFuture + 3) ->
    ok.

new_message_appear(TypeOfPool) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "scaler"),
    gen_server:cast(AtomFromString, upscale).
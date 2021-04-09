-module(worker_scaler).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_cast/2, handle_info/2, new_message_appear/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    MessageCounter = 0,
    erlang:start_timer(0, ?MODULE, secondsexpired),
    {ok, MessageCounter}.



start_new_child() ->
    worker_supervisor:add_new_child().

remove_child() ->
    ok.

handle_cast(upscale, MessageCounter) ->
    MessageCounter + 1.

handle_info({secondsexpired, _, _}, MessageCounter) ->
    NrOfWorkersFuture = calculate_number_of_workers(MessageCounter),
    NrOfWorkersCurrent= length(worker_supervisor:get_all_children()),
    handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent),
    erlang:start_timer(1, self(), secondsexpired),
    {noreply, MessageCounter = 0}.

calculate_number_of_workers(MessageCounter) when MessageCounter < 100 ->
    1;
calculate_number_of_workers(MessageCounter) ->
    MessageCounter div 100.

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent) when NrOfWorkersCurrent  < NrOfWorkersFuture ->
    worker_supervisor:add_new_child(),
    handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent + 1);

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent) when NrOfWorkersCurrent > NrOfWorkersFuture ->
    worker_supervisor:remove_child();

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent) when NrOfWorkersCurrent =:= NrOfWorkersFuture ->
    ok.

new_message_appear() ->
    gen_server:cast(?MODULE, upscale).
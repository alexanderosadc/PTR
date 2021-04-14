-module(worker_scaler).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_cast/2, handle_info/2, new_message_appear/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    MessageCounter = 0,
    erlang:start_timer(0, ?MODULE, secondsexpired),
    {ok, MessageCounter}.

handle_cast(upscale, MessageCounter) ->
    {noreply, MessageCounter + 1}.

handle_info({_, _, secondsexpired}, MessageCounter) ->
    NrOfWorkersFuture = calculate_number_of_workers(MessageCounter),
    NrOfSentimentWorkersCurrent = length(worker_supervisor:get_all_children()),

    handle_number_of_workers(NrOfWorkersFuture, NrOfSentimentWorkersCurrent),
    erlang:start_timer(1000, self(), secondsexpired),
    {noreply, 0}.

calculate_number_of_workers(MessageCounter) when MessageCounter < 100 ->
    1;
calculate_number_of_workers(MessageCounter) when MessageCounter >= 100 ->
    MessageCounter div 100.

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent) when NrOfWorkersCurrent  < (NrOfWorkersFuture + 3) ->
    worker_supervisor:add_new_child(),
    handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent + 1);


handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent) when NrOfWorkersCurrent > (NrOfWorkersFuture + 3) ->
    worker_supervisor:remove_one_child();

handle_number_of_workers(NrOfWorkersFuture, NrOfWorkersCurrent) when NrOfWorkersCurrent =:= (NrOfWorkersFuture + 3) ->
    ok.

new_message_appear() ->
    gen_server:cast(?MODULE, upscale).
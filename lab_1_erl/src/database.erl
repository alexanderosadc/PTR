-module(database).

-behaviour(gen_server).
-export([send_message/1, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link({local, database}, ?MODULE, [], []).

init([]) ->
    erlang:start_timer(200, batcher, secondsexpired),
    {ok, []}.

send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).


handle_cast({send_message, RecievedMessage}, State) ->
    io:format("~p~p ~n", ["Database =", length(RecievedMessage)]),
    {noreply, State}.
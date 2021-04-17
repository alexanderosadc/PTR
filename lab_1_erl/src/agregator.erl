-module(agregator).

-behaviour(gen_server).

-export([send_message/1, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, 1}.

send_message(Message) ->
    io:format("~p~p ~n", ["Event Data =", Message]),
    gen_server:cast(?MODULE, {send_message, Message}).

handle_cast({send_message, EventData}, State) ->
    
    {noreply, State}.

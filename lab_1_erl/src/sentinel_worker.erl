-module(sentinel_worker).
-behaviour(gen_server).
-export([send_message/2, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, {}}.

send_message(EventMessageBinary, Pid) ->
    gen_server:cast(Pid, {send_message, EventMessageBinary}).
    
handle_cast({send_message, EventMessageBinary}, State) ->
    io:format("~p: ~p ~n", [self(), byte_size(EventMessageBinary)]),
    {noreply, State}.
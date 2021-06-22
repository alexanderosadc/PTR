-module(connection_parser).

-behaviour(gen_server).

-export([send_message/1, start_link/0, init/1, handle_cast/2, handle_info/2, start_server/1]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    start_server(8091),
    {ok, []}.
 
send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).

handle_cast({send_message, RecievedMessage}, ListOfMessages) ->
    {noreply, noreply}.

handle_info({_, _, secondsexpired}, ListOfMessages) ->
    {noreply, []}.

start_server(Port) ->
    Pid = spawn_link(fun() ->
        {ok, Listen} = gen_tcp:listen(Port, [binary, {active, false}]),
        spawn(
            fun() -> acceptor(Listen) end),
            timer:sleep(infinity)
        end),
        
    {ok, Pid}.
 
acceptor(ListenSocket) ->
    {ok, Socket} = gen_tcp:accept(ListenSocket),
    spawn(fun() -> acceptor(ListenSocket) end),
    handle(Socket).
 
%% Echoing back whatever was obtained
handle(Socket) ->
    inet:setopts(Socket, [{active, once}]),
    receive
        {tcp, Socket, <<"quit", _/binary>>} ->
        gen_tcp:close(Socket);
        {tcp, Socket, Msg} ->
            io:format("~p", [Msg]),
            gen_tcp:send(Socket, Msg),
        handle(Socket)
    end.
{topic=, message=, command=,}
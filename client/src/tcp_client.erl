-module(tcp_client).

-behaviour(gen_server).

-export([send_message/1, start_link/0, init/1, handle_cast/2, handle_info/2, start_client/0]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    Sock = start_client(),
    send_data(Sock, "connect_publisher", "event_score", "asfas"),
    % send_data(Sock, "msg_publisher", "event_score", "BlahBlahBlah"),
    % close_connection(Sock),
    {ok, []}.

send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).

handle_cast({send_message, RecievedMessage}, ListOfMessages) ->
    {noreply, noreply}.

handle_info({_, _, secondsexpired}, ListOfMessages) ->
    {noreply, []}.

start_client() ->
    SomeHostInNet = "localhost", % to make it runnable on one machine
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, 8091, 
                                [binary, {packet, 0}], 1000),
    Sock.
    

send_data(Sock, Command, Topic, Message) ->
    JsonString = jsx:encode(#{<<"command">> => Command, <<"topic">> => Topic, <<"message">> => Message}),        
    gen_tcp:send(Sock, JsonString).

close_connection(Sock) ->
    gen_tcp:close(Sock).
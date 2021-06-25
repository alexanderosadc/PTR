-module(tcp_client).

-behaviour(gen_server).

-export([start_link/0, init/1, send_message/3, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("~p: ~p~n", ["Client", self()]),
    {ok, Socket} = gen_tcp:connect(
        "localhost",
        8091, 
    [{active, false}, {packet, 2}]
    ),
    {ok, Socket}.

send_message(Command, Topic, Msg) ->
    EncodedJson = transform_to_json(Command, Topic, Msg),
    gen_server:cast(?MODULE, {send, EncodedJson}).

handle_call(_, _, _State) ->
    {noreply, _State}.

handle_cast({send, Message}, Socket) ->
    io:format("Encoded JSON: ~p~n", [Message]),
    gen_tcp:send(Socket, Message),
    {noreply, Socket}.

handle_info({_, _, Data}, _State) ->
    io:format("Client Received: ~p~n", [Data]),
    {noreply, _State}.

transform_to_json(Command, Topic, Message) ->
    jsx:encode(#{<<"command">> => Command, <<"topic">> => Topic, <<"message">> => Message}).   
    % gen_tcp:send(Sock, JsonString).

close_connection(Sock) ->
    gen_tcp:close(Sock).
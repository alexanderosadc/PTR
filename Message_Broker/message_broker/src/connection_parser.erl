-module(connection_parser).

-behaviour(gen_server).

-export([send_message/1, start_link/0, init/1, handle_cast/2, start_server/1, parse_message/1]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    start_server(8091),
    {ok, []}.
 
send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).

handle_cast({send_message, RecievedMessage}, State) ->
    {noreply, noreply}.

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
        {tcp, Socket, Msg} ->
            io:format("~p ~n", ["ASFKJASFJASKFJASFJLKJLSAF"]),
            DecodedJson = parse_message(Msg),

            #{
                <<"command">> := Command
            } = DecodedJson,

            handle_command(Command, DecodedJson, Socket),
            gen_tcp:send(Socket, Msg),
        handle(Socket)
    end.

parse_message(Msg) ->
    DecodedJson = jsx:decode(Msg),
    DecodedJson.

handle_command("connect_publisher", DecodedJson, _) ->
    publisher_memory:send_message(DecodedJson),
    ok;
handle_command("disconnect_publisher", _, Socket) ->
    io:format("~p ~n", ["Publisher Disconnected"]),
    gen_tcp:close(Socket);
handle_command("msg_publisher", DecodedJson, _) ->
    #{
        <<"topic">> := Topic,
        <<"message">> := Message
    } = DecodedJson,
    AtomTopic = list_to_atom(Topic),
    AtomTopic:send_message(Message),
    ok;

handle_command("connect_client", DecodedJson, _) ->
    ok;
handle_command("disconnect_client", DecodedJson, _) ->
    ok;
handle_command("subscribe_client", DecodedJson, _) ->
    ok;
handle_command("unsubscribe_client", DecodedJson, _) ->
    ok;
handle_command("listoftopics_client", DecodedJson, _) ->
    ok.
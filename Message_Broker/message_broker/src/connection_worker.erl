-module(connection_worker).

-behaviour(gen_server).
% decode_data(Data, Socket),
-export([send_message/1, start_link/1, init/1, handle_cast/2, handle_call/3, handle_info/2]).

start_link(Socket) ->
    gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    % io:format("~p: ~p~n", ["Connection", self()]),
    gen_server:cast(self(), {accept}),

    % Listen server
    % Accept
    
    {ok, Socket}.

send_message({UniquePID, RecievedMessage}) ->
    io:format("Send Message Connection Worker: ~p~n", [RecievedMessage]),
    gen_server:cast(UniquePID, RecievedMessage).

handle_cast({accept}, Socket) ->
    {ok, NewSocket} = gen_tcp:accept(Socket),
    % connection_supervisor:spawn_childs(1),
    io:format("Accepted Socket: ~p~n", [NewSocket]),
    {noreply, NewSocket};

handle_cast(RecievedMessage, Socket) ->
    io:format("~p~n", ["Handle CAST"]),
    gen_tcp:send(Socket, RecievedMessage),
    % send_messages_to_client(SubscribersSokcetList, RecievedMessage),
    {noreply, Socket}.

handle_info({_, _, Data}, Socket) ->
    % Answer = lab3_process:process(Data),
    % NewData = <<Data>>,
    Answer = Data,
    
    decode_data(Data, self()),

    % gen_tcp:send(Socket, Answer),
    % inet:setopts(Socket, [{active, once}]),

    {noreply, Socket}.

handle_call({_, _}, Socket, _)->
    {noreply, Socket}.


decode_data(Data, Socket) ->
    NewData = list_to_binary(Data),
    DecodedJson = jsx:decode(NewData),

            #{
                <<"command">> := Command
            } = DecodedJson,
            % io:format("~p ~n", [Command]),
            handle_command(Command, DecodedJson, Socket).

handle_command("connect_publisher", DecodedJson, _) ->
    publisher_memory:send_message({"verify_topics", DecodedJson}),
    ok;
handle_command("disconnect_publisher", _, Socket) ->
    io:format("~p ~n", ["Publisher Disconnected"]),
    gen_tcp:close(Socket);
handle_command("msg_publisher", DecodedJson, _) ->
    #{
        <<"command">> := Command,
        <<"topic">> := Topic,
        <<"message">> := Message
    } = DecodedJson,
    AtomTopic = list_to_atom(Topic),
    % io:format("~p ~n", [AtomTopic]),
    topic_worker:send_message(Command, {Message, AtomTopic}),
    ok;

handle_command("connect_client", DecodedJson, _) ->
    ok;
handle_command("disconnect_client", DecodedJson, _) ->
    ok;
handle_command("subscribe_client", DecodedJson, Socket) ->
    #{
        <<"topic">> := Topic
    } = DecodedJson,
    AtomTopic = list_to_atom(Topic),
    subscriber_memory:send_message({"subscribe_client", AtomTopic, Socket});
handle_command("unsubscribe_client", DecodedJson, Socket) ->
    #{
        <<"topic">> := Topic
    } = DecodedJson,
    AtomTopic = list_to_atom(Topic),
    subscriber_memory:send_message({"unsubscribe_client", AtomTopic, Socket});

handle_command("listoftopics_client", DecodedJson, Socket) ->
    Response = #{list_of_topics => subscriber_memory:send_message("list_of_topics")},
    EncodedJson = jsx:encode(Response),
    io:format("~p ~n", [Response]),
    gen_tcp:send(Socket, EncodedJson).
    % EncodedJson.
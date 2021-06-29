-module(topic_worker).

-behaviour(gen_server).

-export([handle_call/3, send_message/2, start_link/1, init/1, handle_cast/2]).

start_link(NameOfChild) ->
    MessageQueue = [],
    SubscribersSokcetList = [],
    {ok, Pid} = gen_server:start_link({local, NameOfChild}, ?MODULE, [{MessageQueue, SubscribersSokcetList}], []),
    {ok, Pid}.

init([Data]) ->
    {ok, Data}.

handle_call({_, _}, {MessageQueue, SubscribersSokcetList}, _)->
    {noreply, {MessageQueue, SubscribersSokcetList}}.
 
send_message(Command, {Message, AtomTopic}) ->
    gen_server:cast(AtomTopic, {Command, Message}).

handle_cast({"msg_publisher", RecievedMessage}, {MessageQueue, SubscribersSokcetList}) ->
    io:format("Recieved Message ~p ~n", [RecievedMessage]),
    NewMessageQueue = [RecievedMessage | MessageQueue],
    send_messages_to_client(SubscribersSokcetList, RecievedMessage),
    % connection_worker:send_message({"send_msg", SubscribersSokcetList, RecievedMessage}),
    {noreply, {NewMessageQueue, SubscribersSokcetList}};

handle_cast({"subscribe_client", Socket}, {MessageQueue, SubscribersSokcetList}) ->
    io:format("~p ~n", ["Connected to topic"]),
    NewSocketList = [Socket | SubscribersSokcetList],
    {noreply, {MessageQueue, NewSocketList}};

handle_cast({"unsubscribe_client", Socket}, {MessageQueue, SubscribersSokcetList}) ->
    io:format("~p ~n", ["Unsubscribed from topic"]),
    NewSocketList = lists:delete(Socket,SubscribersSokcetList),
    {noreply, {MessageQueue, NewSocketList}}.

send_messages_to_client(ListOfPids, RecievedMessage) when length(ListOfPids) > 0 ->
    [UniquePID | NewList] = ListOfPids,
    connection_worker:send_message({UniquePID, RecievedMessage}),
    send_messages_to_client(NewList, RecievedMessage);

send_messages_to_client(SubscribersSokcetList, RecievedMessage) ->
    ok.
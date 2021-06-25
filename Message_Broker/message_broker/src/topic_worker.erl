-module(topic_worker).

-behaviour(gen_server).

-export([handle_call/3, send_message/2, start_link/1, init/1, handle_cast/2]).

start_link(NameOfChild) ->
    MessageQueue = [],
    {ok, Pid} = gen_server:start_link({local, NameOfChild}, ?MODULE, [MessageQueue], []),
    {ok, Pid}.

init([MessageQueue]) ->
    {ok, MessageQueue}.

handle_call({_, _}, MessageQueue, _)->
    {noreply, MessageQueue}.
 
send_message(Message, AtomTopic) ->
    gen_server:cast(AtomTopic, {send_message, Message}).

handle_cast({send_message, RecievedMessage}, MessageQueue) ->
    NewMessageQueue = [RecievedMessage | MessageQueue],
    {noreply, NewMessageQueue}.
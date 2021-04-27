-module(batcher).

-behaviour(gen_server).
-export([send_message/1, start_link/0, init/1 ,handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link({local, batcher}, ?MODULE, [], []).

init([]) ->
    erlang:start_timer(10000, batcher, secondsexpired),
    {ok, []}.

send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).


handle_cast({send_message, RecievedMessage}, ListOfMessages) ->
    AppendedListOfMessages = collect_messages(RecievedMessage, ListOfMessages),
    UpdatedListOfMessages = send_message_to_db(length(AppendedListOfMessages), AppendedListOfMessages),
    {noreply, UpdatedListOfMessages}.

handle_info({_, _, secondsexpired}, ListOfMessages) ->
    send_message_from_timer(ListOfMessages),
    erlang:start_timer(10000, self(), secondsexpired),
    {noreply, []}.

collect_messages(Message, ListOfMessages) ->
    [Message | ListOfMessages].

send_message_to_db(128, ListOfMessages) ->
    database:send_message(ListOfMessages),
    [];

send_message_to_db(_, ListOfMessages)->
    ListOfMessages.

send_message_from_timer(ListOfMessages) when length(ListOfMessages) > 0 ->
    database:send_message(ListOfMessages);

send_message_from_timer(ListOfMessages) ->
    ok.
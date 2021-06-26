-module(subscriber_memory).

-behaviour(gen_server).

-export([handle_call/3, send_message/1, start_link/0, init/1, handle_cast/2]).

start_link() ->
    gen_server:start_link({local, subscriber_memory}, ?MODULE, [], []).

init([]) ->
    {ok, noreply}.

send_message("list_of_topics") ->
    gen_server:call(?MODULE, "list_of_topics");

send_message(Message) ->
    gen_server:cast(?MODULE, Message).

handle_call("list_of_topics", From, State)->
    ListOfTopics = publisher_memory:send_message("list_of_topics"),
    {reply, ListOfTopics, State}.
 
handle_cast({"subscribe_client", AtomTopic, Socket}, State) ->
    ListOfTopics = publisher_memory:send_message("list_of_topics"),
    IsTopicInList = lists:member(AtomTopic, ListOfTopics),
    io:format("~p ~n", [IsTopicInList]),
    % create_topic(),
    connect_to_topic_worker(AtomTopic, Socket, IsTopicInList),
    {noreply, State};

handle_cast({"unsubscribe_client", AtomTopic, Socket}, State) ->
    ListOfTopics = publisher_memory:send_message("list_of_topics"),
    IsTopicInList = lists:member(AtomTopic, ListOfTopics),
    io:format("~p ~n", [IsTopicInList]),
    % create_topic(),
    unsubscribe_from_topic(AtomTopic, Socket, IsTopicInList),
    {noreply, State}.

connect_to_topic_worker(AtomTopic, Socket, true) ->
    topic_worker:send_message("subscribe_client", {Socket, AtomTopic});

connect_to_topic_worker(_, _, _) ->
    ok.

unsubscribe_from_topic(AtomTopic, Socket, true) ->
    topic_worker:send_message("unsubscribe_client", {Socket, AtomTopic});

unsubscribe_from_topic(_, _, _) ->
    ok.
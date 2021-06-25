-module(publisher_memory).
-behaviour(gen_server).

-export([handle_call/3, send_message/1, start_link/0, init/1, handle_cast/2, add_new_topic/4]).

start_link() ->
    ListOfTopics = [],
    gen_server:start_link({local, publisher_memory}, ?MODULE, ListOfTopics, []).

init(ListOfTopics) ->

    {ok, ListOfTopics}.
 
send_message({"verify_topics", Message}) ->
    gen_server:cast(?MODULE, {"send_message", Message});

send_message("list_of_topics") ->
    gen_server:call(?MODULE, "list_of_topics").

handle_cast({"send_message", RecievedMessage}, ListOfTopics) ->
    #{
        <<"topic">> := Topic,
        <<"command">> := Command
    } = RecievedMessage,
    
    AtomTopic = list_to_atom(Topic),
    % io:format("~p ~n", [ListOfTopics]),
    % io:format("~p ~n", [AtomTopic]),
    IsTopicInList = lists:member(AtomTopic, ListOfTopics),
    ListOfTopicsToSend = add_new_topic(AtomTopic, ListOfTopics, Command, IsTopicInList),
    % io:format("~p ~n", [ListOfTopicsToSend]),
    {noreply, ListOfTopicsToSend}.

handle_call("list_of_topics", From, ListOfTopics)->
    {reply, ListOfTopics, ListOfTopics}.
% Add new Topic
add_new_topic(AtomTopic, ListOfTopics, "connect_publisher", false) ->
    topic_supervisor:add_new_child(AtomTopic),
    [AtomTopic | ListOfTopics];
add_new_topic(_,ListOfTopics, _, true) ->
    ListOfTopics.
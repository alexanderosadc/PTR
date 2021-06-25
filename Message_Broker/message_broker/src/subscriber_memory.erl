-module(subscriber_memory).

-behaviour(gen_server).

-export([handle_call/3, send_message/1, start_link/0, init/1, handle_cast/2]).

start_link() ->
    gen_server:start_link({local, subscriber_memory}, ?MODULE, [], []).

init([]) ->
    {ok, noreply}.

send_message("list_of_topics") ->
    gen_server:call(?MODULE, "list_of_topics").

handle_call("list_of_topics", From, State)->
    ListOfTopics = publisher_memory:send_message("list_of_topics"),
    {reply, ListOfTopics, State}.
 
handle_cast({"list_of_topics", ListOfTopics}, State) ->
    
    {noreply, State}.
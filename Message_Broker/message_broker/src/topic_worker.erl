-module(topic_worker).

-behaviour(gen_server).

-export([handle_call/3, send_message/2, start_link/1, init/1, handle_cast/2]).

start_link(NameOfChild) ->
    io:format("~p ~n", ["blahblahblah"]),
    {ok, Pid} = gen_server:start_link({local, NameOfChild}, ?MODULE, [], []),
    {ok, Pid}.

init([]) ->
    {ok, 1}.

handle_call({_, _}, ListOfTopics, _)->
    {noreply, ListOfTopics}.
 
send_message(Message, AtomName) ->
    gen_server:cast(AtomName, {send_message, Message}).

handle_cast({send_message, RecievedMessage}, State) ->
    {noreply, State}.
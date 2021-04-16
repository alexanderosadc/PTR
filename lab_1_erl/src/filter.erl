-module(filter).
-behaviour(gen_server).

-export([handle_call/3, handle_cast/2, init/1, start_link/0, send_message/1]).

start_link() ->
    gen_server:start_link({local, filter}, ?MODULE, [], []).

init([]) ->
    {ok, 1}.

handle_call({_, _}, State, _)->
    {noreply, State}.

handle_cast({send_message, EventMessageBinary}, State) ->
    EventMap = shotgun:parse_event(EventMessageBinary),
    #{data := EventData} = EventMap,
    % io:format("~p~p ~n", ["Sentiment =", EventData]),
    NewId = send_data_to_routers(EventData, jsx:is_json(EventData), State),
    {noreply, NewId}.

send_data_to_routers(EventData, IsJson, Id) ->
    {NewId, NewMap} = assign_id_to_map(EventData, IsJson, Id),
    worker_router:send_message(sentiment, NewMap),
    worker_router:send_message(engagement, NewMap),
    NewId.

assign_id_to_map(EventData, IsJson, Id) when IsJson =:= true->
    DecodedJson = jsx:decode(EventData),
    NewMap = maps:put("Twitter_ID", Id, DecodedJson),
    NewId = Id + 1,
    {NewId, NewMap};

assign_id_to_map(EventData, IsJson, Id) ->
    io:format("~p~p ~n", ["EventData", EventData]),
    {Id, EventData}.

send_message(EventMessageBinary) ->
    gen_server:cast(?MODULE, {send_message, EventMessageBinary}).
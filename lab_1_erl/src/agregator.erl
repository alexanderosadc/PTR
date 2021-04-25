-module(agregator).
-behaviour(gen_server).
-export([send_message/1, start_link/0, init/1 ,handle_cast/2]).

start_link() ->
    gen_server:start_link({local, agregator}, ?MODULE, [], []).

init([]) ->
    {ok, #{}}.

send_message(Message) ->
    gen_server:cast(?MODULE, {send_message, Message}).


handle_cast({send_message, RecievedMap}, MapOfMaps) ->
    MapId = maps:get(<<"Twitter_ID">>, RecievedMap),
    IsIdFound = check_ID(MapId, MapOfMaps),

    NewMapOfMaps = map_enlarger(IsIdFound, MapId, RecievedMap, MapOfMaps),
    % io:format("~p~p ~n", ["EventData =", MapOfMaps]),
    {noreply, NewMapOfMaps}.

map_enlarger(false, MapId, RecievedMap, MapOfMaps) ->
    StringMapId = string:concat("Map_", integer_to_list(MapId)),
    NewMapElement = maps:put(StringMapId, RecievedMap, #{}),
    maps:merge(MapOfMaps, NewMapElement);

map_enlarger(true, MapId, RecievedMap, MapOfMaps) ->
    StringMapId = string:concat("Map_", integer_to_list(MapId)),
    ElementFromMap = maps:get(StringMapId, MapOfMaps),
    
    MergedMaps = maps:merge(ElementFromMap, RecievedMap),
    NewMapElement = maps:put(StringMapId, MergedMaps, #{}),
    MergedMapOfMaps = maps:merge(MapOfMaps, NewMapElement),
    
    io:format("~p~p ~n", ["MergedMaps", MergedMapOfMaps]),
    MergedMapOfMaps.

check_ID(Id, MapOfMaps) ->
    StringMapId = string:concat("Map_", integer_to_list(Id)),
    maps:is_key(StringMapId, MapOfMaps).
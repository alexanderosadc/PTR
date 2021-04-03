-module(test).

-export([init/0]).

init() ->
    initialize_workers(3).

initialize_workers(N) when N == 0 -> 
    ok;
initialize_workers(N) when N > 0 ->
    io:format("~p: ~p ~n", [self(), N]),
    initialize_workers(N - 1).
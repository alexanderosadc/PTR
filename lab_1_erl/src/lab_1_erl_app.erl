%%%-------------------------------------------------------------------
%% @doc lab_1_erl public API
%% @end
%%%-------------------------------------------------------------------

-module(lab_1_erl_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    lab_1_erl_sup:start_link().

stop(_State) ->
    ok.

%% internal functions

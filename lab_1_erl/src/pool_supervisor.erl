-module(pool_supervisor).

-behaviour(supervisor).

-export([init/1, start_link/1]).

start_link(TypeOfPool) ->
    supervisor:start_link(?MODULE, TypeOfPool).

init(TypeOfPool) ->
    MaxRestart = 6,
    MaxTime = 100,

    SupFlags = #{
        strategy => one_for_one,
		intensity => MaxRestart, 
        period => MaxTime
    },

    Router = #{
        id => router,
	    start => {worker_router, start_link, [TypeOfPool]},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [worker_router]
    },

    Scaler = #{
        id => worker_scaler,
        start => {worker_scaler, start_link, [TypeOfPool]},
        restart => permanent, 
        shutdown => 2000, 
        type => worker,
        modules => [worker_scaler]
        },

    WorkerSupervisor = #{
        id => worker_supervisor,
	    start => {worker_supervisor, start_link, [TypeOfPool]},
	    restart => permanent,
        shutdown => 2000, 
        type => supervisor,
	    modules => [worker_supervisor]
    },


    
    ChildSpecs = [WorkerSupervisor, Scaler, Router],
    {ok, {SupFlags, ChildSpecs}}.

get_all_children() ->
    ChildrenProcessData = supervisor:which_children(?MODULE),
    lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).
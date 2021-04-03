-module(worker_supervisor).

-behaviour(supervisor).

-export([start_link/0, init/1, add_new_child/0, get_all_children/0]).

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    {ok, Pid}.

init(_Args) ->
    MaxRestart = 2,
    MaxTime = 100,
    SupFlags = #{
        strategy => simple_one_for_one,
		intensity => MaxRestart, 
        period => MaxTime
    },
    
    ChildWorker = #{
        id => sentinel_worker,
	    start => {sentinel_worker, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [sentinel_worker]},
    
    ChildSpecs = [ChildWorker],
    {ok, {SupFlags, ChildSpecs}}.

add_new_child() ->
    
    supervisor:start_child(?MODULE, []).

get_all_children() ->
    supervisor:which_children(?MODULE).
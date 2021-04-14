-module(worker_supervisor).

-behaviour(supervisor).

-export([start_link/1, init/1, add_new_child/0, get_all_children/0, remove_one_child/0]).

start_link(TypeOfPool) ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, [TypeOfPool]),
    {ok, Pid}.

init(TypeOfPool) ->
    MaxRestart = 6,
    MaxTime = 100,
    SupFlags = #{
        strategy => simple_one_for_one,
		intensity => MaxRestart, 
        period => MaxTime
    },
    
    ChildWorker = #{
        id => simple_worker,
	    start => {simple_worker, start_link, [TypeOfPool]},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [simple_worker]},
    
    ChildSpecs = [ChildWorker],
    {ok, {SupFlags, ChildSpecs}}.

add_new_child() ->
    
    supervisor:start_child(?MODULE, []).

remove_one_child() ->
    ChildPIDS = get_all_children(),
    [FirstChild | _ ] = ChildPIDS,
    supervisor:terminate_child(?MODULE, FirstChild).

get_all_children() ->
    ChildrenProcessData = supervisor:which_children(?MODULE),
    lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).
-module(worker_supervisor).

-behaviour(supervisor).

-export([start_link/1, init/1, add_new_child/1, get_all_children/1, remove_one_child/1]).

start_link(TypeOfPool) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "supervisor"),
    {ok, Pid} = supervisor:start_link({local, AtomFromString}, ?MODULE, [TypeOfPool]),
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

add_new_child(TypeOfPool) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "supervisor"),
    supervisor:start_child(AtomFromString, []).

remove_one_child(TypeOfPool) ->
    % io:format("~p ~n", ["Remove One Child"]),
    AtomFromString = useful_functions:get_atom(TypeOfPool, "supervisor"),
    ChildPIDS = get_all_children(TypeOfPool),
    [FirstChild | _ ] = ChildPIDS,
    supervisor:terminate_child(AtomFromString, FirstChild).

get_all_children(TypeOfPool) ->
    AtomFromString = useful_functions:get_atom(TypeOfPool, "supervisor"),
    ChildrenProcessData = supervisor:which_children(AtomFromString),
    lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).
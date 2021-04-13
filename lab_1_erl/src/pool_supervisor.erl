-module(pool_supervisor).

-behaviour(supervisor).

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    {ok, Pid}.

init(_Args) ->
    MaxRestart = 6,
    MaxTime = 100,

    
    SupFlags = #{
        strategy => simple_one_for_one,
		intensity => MaxRestart, 
        period => MaxTime
    },

    Supervisor = #{
        id => engagement_ratio_worker,
	    start => {engagement_ratio_worker, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [engagement_ratio_worker]},
    },
    
    ChildWorker = #{
        id => engagement_ratio_worker,
	    start => {engagement_ratio_worker, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [engagement_ratio_worker]},
    
    ChildSpecs = [ChildWorker],
    {ok, {SupFlags, ChildSpecs}}.

get_all_children() ->
    ChildrenProcessData = supervisor:which_children(?MODULE),
    lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).
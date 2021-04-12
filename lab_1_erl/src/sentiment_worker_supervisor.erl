-module(sentiment_worker_supervisor).

-behaviour(supervisor).

-export([start_link/0, init/1, add_new_child/0, get_all_children/0, remove_one_child/0]).

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
    
    ChildWorker = #{
        id => sentiment_score_worker,
	    start => {sentiment_score_worker, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [sentiment_score_worker]},
    
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
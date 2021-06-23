-module(topic_supervisor).

-behaviour(supervisor).

-export([start_link/0, init/1, add_new_child/1, get_all_children/0]).

start_link() ->
    io:format("~p ~n", ["I'm supervisor"]),
    {ok, Pid} =  supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    {ok, Pid}.

init([]) ->
    MaxRestart = 6,
    MaxTime = 100,
    SupFlags = #{
        strategy => simple_one_for_one,
		intensity => MaxRestart, 
        period => MaxTime
    },
    
    TopicWorker = #{
        id => topic_worker,
	    start => {topic_worker, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [topic_worker]},
    
    ChildSpecs = [TopicWorker],
    {ok, {SupFlags, ChildSpecs}}.

add_new_child(NameOfChild) ->
    supervisor:start_child(?MODULE, [NameOfChild]).

get_all_children() ->
    ChildrenProcessData = supervisor:which_children(topic_supervisor),
    io:format("~p ~n", [ChildrenProcessData]),
    lists:map(fun({_, ChildPid, _, _}) -> ChildPid end, ChildrenProcessData).
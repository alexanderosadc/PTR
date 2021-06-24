-module(connection_supervisor).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

    MaxRestart = 2,
    MaxTime = 100,
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => MaxRestart,
                 period => MaxTime},
    
    {ok, NewSocket} = gen_tcp:listen(8091, [{active, true}, {packet, 2}]),
    spawn_link(fun start_child/0),

    ConnectionWorker = #{
        id => connection_worker,
	    start => {connection_worker, start_link, [NewSocket]},
	    restart => temporary, 
        shutdown => 2000, 
        type => worker,
	    modules => [connection_worker]},

    ChildSpecs = [ConnectionWorker],
    {ok, {SupFlags, ChildSpecs}}.


start_child() ->
    spawn_childs(20).

spawn_childs(Number) when Number > 0 ->
    supervisor:start_child(?MODULE, []),
    spawn_childs(Number - 1);

spawn_childs(_) ->
    0.
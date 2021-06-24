-module(client_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

    MaxRestart = 2,
    MaxTime = 100,
    SupFlags = #{strategy => one_for_all,
                 intensity => MaxRestart,
                 period => MaxTime},
    
    io:format("~p: ~p~n", ["ClientSupervisor", self()]),
     
     TCPClient = #{
        id => tcp_client,
	    start => {tcp_client, start_link, []},
	    restart => temporary, 
        shutdown => 2000, 
        type => worker,
	    modules => [tcp_client]},
        % io:format("~p", ["Started Supervisor"]),

    
    ChildSpecs = [TCPClient],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

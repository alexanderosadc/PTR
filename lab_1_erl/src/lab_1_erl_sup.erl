%%%-------------------------------------------------------------------
%% @doc lab_1_erl top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(lab_1_erl_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    MaxRestart = 2,
    MaxTime = 100,

    SupFlags = #{strategy => one_for_all,
		        intensity => MaxRestart, 
                period => MaxTime},
    
    Stream1 = "/tweets/1",
    
    Reader = #{
        id => reader,
	    start => {reader, start, [Stream1]},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [reader]},
    
    Router = #{
        id => router,
	    start => {worker_router, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [worker_router]},
    
    Supervisor = #{
        id => worker_supervisor,
	    start => {worker_supervisor, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => supervisor,
	    modules => [worker_supervisor]},
    
    Scaler = #{
        id => worker_scaler,
	    start => {worker_scaler, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [worker_scaler]},

    % WorkerStarter = #{
    %     id => workerStarter,
	%     start => {sentinel_worker, start_link, []},
	%     restart => permanent, 
    %     shutdown => 2000, 
    %     type => worker,
	%     modules => [sentinel_worker]},


    ChildSpecs = [Supervisor, Scaler, Router, Reader],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

%%%-------------------------------------------------------------------
%% @doc lab_1_erl top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(lab_1_erl_sup).

-behaviour(supervisor).

-export([init/1, start_link/0]).

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
    Stream2 = "/tweets/2",
    
    Agregator = #{
        id => agregator,
	    start => {agregator, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [agregator]},

    Filter = #{
        id => filter,
	    start => {filter, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [filter]},
    
    Reader1 = #{
        id => reader1,
	    start => {reader, start, [Stream1]},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [reader]},
    
    Reader2 = #{
        id => reader2,
	    start => {reader, start, [Stream2]},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [reader]},
    

    PoolSupervisorEngagement = #{
        id => pool_supervisor_engagement,
	    start => {pool_supervisor, start_link, [engagement]},
	    restart => permanent, 
        shutdown => 2000, 
        type => supervisor,
	    modules => [pool_supervisor]},
    
    PoolSupervisorSentiment = #{
        id => pool_supervisor_sentiment,
	    start => {pool_supervisor, start_link, [sentiment]},
	    restart => permanent, 
        shutdown => 2000, 
        type => supervisor,
        modules => [pool_supervisor]},
    % WorkerStarter = #{
    %     id => workerStarter,
	%     start => {sentinel_worker, start_link, []},
	%     restart => permanent, 
    %     shutdown => 2000, 
    %     type => worker,
	%     modules => [sentinel_worker]},


    ChildSpecs = [Agregator, Filter, PoolSupervisorSentiment, PoolSupervisorEngagement, Reader1, Reader2],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

%%%-------------------------------------------------------------------
%% @doc client top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(client_sup).

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

    Client = #{
        id => tcp_client,
	    start => {tcp_client, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [tcp_client]},
        io:format("~p", ["Started Supervisor"]),

    
    ChildSpecs = [Client],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

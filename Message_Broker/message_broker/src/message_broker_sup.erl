%%%-------------------------------------------------------------------
%% @doc message_broker top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(message_broker_sup).

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
    % io:format("~p", ["Database Tweets ="]),
    MaxRestart = 2,
    MaxTime = 100,
    SupFlags = #{strategy => one_for_all,
                 intensity => MaxRestart,
                 period => MaxTime},
    

    ConnectionSupervisor = #{
        id => connection_supervisor,
	    start => {connection_supervisor, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => supervisor,
	    modules => [connection_supervisor]},

    PublisherMemeory = #{
        id => publisher_memory,
	    start => {publisher_memory, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => worker,
	    modules => [publisher_memory]},
    
    TopicSupervisor = #{
        id => topic_supervisor,
	    start => {topic_supervisor, start_link, []},
	    restart => permanent, 
        shutdown => 2000, 
        type => supervisor,
	    modules => [topic_supervisor]},

    ChildSpecs = [ConnectionSupervisor, PublisherMemeory, TopicSupervisor],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
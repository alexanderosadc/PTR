-module(reader).

-export([start/1]).

start(Stream) ->
    {Pid, _} = spawn_monitor(
    fun () -> 
        start_reader_download(Stream) 
    end),
    % io:format("~p~p~n", ["started conn", Pid]),
    {ok, Pid}.

start_reader_download(Stream) ->
    
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{
        async => true, 
        async_mode => sse,
		handle_event =>
		    fun (_, _, BinaryMessages) ->
                worker_router:send_message(BinaryMessages) 
            end
        },
    {ok, _Ref} = shotgun:get(Conn, Stream, #{}, Options),
    wait(1000),
    shotgun:close(Conn).

wait(Miliseconds) ->
    receive
    after timer:sleep(Miliseconds * 10) -> {ok}
end.
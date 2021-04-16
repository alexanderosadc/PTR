-module(reader).

-export([start/1]).

start(Stream) ->
    {Pid, _} = spawn_monitor(
    fun () -> 
        start_reader_download(Stream) 
    end),
    {ok, Pid}.

start_reader_download(Stream) ->
    
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{
        async => true, 
        async_mode => sse,
		handle_event =>
		    fun (_, _, BinaryMessages) ->
                filter:send_message(BinaryMessages) 
            end
        },
    {ok, _Ref} = shotgun:get(Conn, Stream, #{}, Options),
    wait(10000),
    shotgun:close(Conn).

wait(Miliseconds) ->
    receive
    after timer:sleep(Miliseconds * 10) -> {ok}
end.
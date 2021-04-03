-module(worker_scaler).

start_new_child() ->
    worker_supervisor:add_new_child().
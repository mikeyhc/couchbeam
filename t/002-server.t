#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pa ./ebin

main(_) ->
    etap:plan(6),
    start_app(),
    case (catch test()) of
        ok ->
            etap:end_tests();
        Other ->
            etap:diag(io_lib:format("Test died abnormally: ~p", [Other])),
            etap:bail()
    end,
    ok.
    
start_app() ->
    application:start(crypto),
    application:start(ecouchdbkit),
    ok.

test() ->
    Data = ecouchdbkit:server_info(default),
    etap:is(proplists:get_value(<<"couchdb">>, Data), <<"Welcome">>, "message ok"),
    F = fun() -> ecouchdbkit:server_info(test) end,
    etap_exception:throws_ok(F, {unknown_couchdb_node,<<"No couchdb node configured for test.">>}, "error node ok"),
    etap:is(ecouchdbkit:open_connection({test, {"127.0.0.1", 5984}}), ok, "open connection"),
    Data1 = ecouchdbkit:server_info(test),
    etap:is(proplists:get_value(<<"couchdb">>, Data1), <<"Welcome">>, "message on new connection ok"),
    etap:is(ecouchdbkit:open_connection({test2, {"127.0.0.1", 5984}}), ok, "open connection"),
    Data2 = ecouchdbkit:server_info(test2),
    etap:is(proplists:get_value(<<"couchdb">>, Data2), <<"Welcome">>, "message on new connection ok"),
    
    ok.

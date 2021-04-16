-module(useful_functions).

-export([get_atom/2]).

get_atom(TypeOfPool, Name) ->
    AtomNameInString = atom_to_list(TypeOfPool),
    RouterNameInString = string:concat(AtomNameInString, Name),
    list_to_atom(RouterNameInString).
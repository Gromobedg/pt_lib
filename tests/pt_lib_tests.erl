%%%-------------------------------------------------------------------
%%% -*- coding: utf-8 -*-
%%% @copyright (C) 2015, Eltex, Novosibirsk, Russia
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(pt_lib_tests).

-include("pt_lib.hrl").
-include_lib("eunit/include/eunit.hrl").

-export([pt_macro_test_/1]).

pt_lib_test_() ->
[
 % known bug #22211
 ?_test(begin {attribute, 5, export, [{func, 3}, {func1, 4}]} = ast("-export([func/3, func1/4]).", 5) end),
 ?_test(begin {attribute, 7, test_attribute, [{func, 3}, {func1, 4}]} = ast("-test_attribute([func/3, func1/4]).", 7) end),
 ?_test(begin {match,8,{var,8,'F'},{'fun',8,{function,func,3}}} = ast("F = fun func/3.", 8) end),
 ?_test(begin {function, 5, f, 1, [{clause, 5, [{'fun', 5, {function, g, 0}}], [], [{call, 5, {atom, 5, g}, []}]}]} = ast("f(fun g/0) -> g().", 5) end),
 ?_test(begin {call, 10, {atom, 10, log}, [{var, 10, 'String'}]} = ast("log(String).", 10) end),
 ?_test(begin String = {atom, 0, a}, {call, 0, {atom, 0, log}, [{atom, 0, a}]} = ast("log('$String').", 0) end),
 ?_test(begin String = a, {call, 0, {atom, 0, log}, [{atom, 0, a}]} = ast("log('@String').", 0) end),
 ?_test(begin {call, 0, {remote, 0, {atom, 0, a}, {atom, 0, log}}, [{var, 0, 'String'}]} = ast("a:log(String).", 0) end),
 ?_test(begin {atom, 1, a} = ast("a.", 1) end),
 ?_test(begin {var, 1, 'A'} = ast("A.", 1) end),
 ?_test(begin {nil, 1} = ast("[].", 1) end),
 ?_test(begin {tuple, 1, []} = ast("{}.", 1) end),
 ?_test(begin {string, 1, "a"} = ast("\"a\".", 1) end),
 ?_test(begin {'fun', 1, {clauses, [{clause, 1, [], [], [{atom, 1, a}, {atom, 1, b}]}]}} = ast("fun () -> a,b end.", 1) end),
 ?_test(begin [{atom, 1, a}, {atom, 1, b}, {atom, 1, c}] = ast("a,b,c.", 1) end),
 ?_test(begin ast_pattern("mod:f(Str, aaa).", Line) = {call, 10, {remote, 11, {atom, 12, mod}, {atom, 13, f}}, [{var, 14, 'Str'}, {atom, 15, aaa}]}, Line = 10 end),
 ?_test(begin ast_pattern("mod:f('$Str', aaa).", Line) = {call, 10, {remote, 11, {atom, 12, mod}, {atom, 13, f}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Line = 10, Str = {string, 14, "Str"} end),
 ?_test(begin ast_pattern("mod:'$F'('$Str', aaa).", Line) = {call, 10, {remote, 11, {atom, 12, mod}, {atom, 13, f}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Line = 10, Str = {string, 14, "Str"}, F = {atom, 13, f} end),
 ?_test(begin ast_pattern("mod:F('$Str', aaa).", Line) = {call, 10, {remote, 11, {atom, 12, mod}, {var, 13, 'F'}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Line = 10, Str = {string, 14, "Str"} end),
 ?_test(begin ast_pattern("Mod:f('$Str', aaa).", Line) = {call, 10, {remote, 11, {var, 12, 'Mod'}, {atom, 13, 'f'}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Line = 10, Str = {string, 14, "Str"} end),
 ?_test(begin ast_pattern("'$Mod':f('$Str', aaa).", Line) = {call, 10, {remote, 11, {atom, 12, 'module_name'}, {atom, 13, 'f'}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Line = 10, Str = {string, 14, "Str"}, Mod = {atom, 12, module_name} end),
 ?_test(begin ast_pattern("'$Mod':f('$Str', aaa).", Line) = {call, 10, {remote, 11, {atom, 12, 'module_name'}, {atom, 13, 'f'}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Line = 10, Str = {string, 14, "Str"}, Mod = {atom, 12, module_name} end),
 ?_test(begin ast_pattern("module_name:f('$Str', aaa).", 10) = {call, 10, {remote, 11, {atom, 12, 'module_name'}, {atom, 13, 'f'}}, [{string, 14, "Str"}, {atom, 15, aaa}]}, Str = {string, 14, "Str"} end),
 ?_test(begin case {call, 1, {remote, 2, {atom, 3, mod}, {atom, 4, f}}, [{var, 5, 'Str'}]} of ast_pattern("mod:f(Str).", Line) -> Line = 1, ok end end),
 ?_test(begin F = fun(_A, {a}, _B) -> failed; (_A, ast_pattern("f()."), _B) -> ok end, F(1, {call, 1, {atom, 2, f}, []}, 2) end),
 ?_test(begin {call, 1, {atom, 2, test_fun}, []} = tst(a, {call, 1, {atom, 2, test_fun}, []}, b) end),
 ?_test(begin ast_pattern("'$F'('$A').") = ast_pattern("log('$B').") = {call, 1, {atom, 2, log}, [{integer, 3, 2}]}, F = {atom, 2, log}, A = B = {integer, 3, 2} end),
 ?_test(begin case {call, 1, {remote, 2, {atom, 3, mod}, {atom, 4, f}}, [{var, 5, 'Str'}]} of ast_pattern("mod:f(Str).", Line) = ast_pattern("mod:f('$_S').") -> Line = 1, ok end end),
 ?_test(begin A = aaa, B = bbb, {'EXIT',{{badmatch,_}, _}} = (catch (ast_pattern("mod:f(Str, '@B').", _) = {call, 10, {remote, 11, {atom, 12, mod}, {atom, 13, f}}, [{var, 14, 'Str'}, {atom, 15, aaa}]})), ast_pattern("mod:f(Str, '@A').", Line) = {call, 10, {remote, 11, {atom, 12, mod}, {atom, 13, f}}, [{var, 14, 'Str'}, {atom, 15, aaa}]}, Line = 10 end),
 ?_test(begin A = aaa, B = 'Str', case ast_pattern("'$M':f('@B',aaa).") = ast_pattern("mod:f('Str', '@A').", Line) = {call, 10, {remote, 11, {atom, 12, mod}, {atom, 13, f}}, [{atom, 14, 'Str'}, {atom, 15, aaa}]} of {call,10,_,_} -> ok end, {atom, _, mod} = M, Line = 10 end),
 ?_test(begin A = 1, B = 2, case {call, 1, {remote, 2, {atom, 3, mod}, {atom, 4, f}}, [{var, 5, 'Str'}, {integer, 6, 1}]} of ast_pattern("mod:f(Str, '@B').", _) -> wrong_clause; ast_pattern("mod:f(Str, '@A').", _) -> ok end end),
 ?_test(begin A = 1, case {call, 1, {remote, 2, {atom, 3, mod}, {atom, 4, f}}, [{integer, 5, 2}, {integer, 6, 1}]} of ast_pattern("mod:f('$Str', '@A').", _) -> Str = {integer, 5, 2}, ok end end),
 ?_test(begin case ast("a.", 0) of B when pt_lib:is_fun(B) -> wrong_clause; A when pt_lib:is_atom(A) -> ok end end),
 ?_test(begin case ast("[a].", 0) of B when pt_lib:is_atom(B) -> wrong_clause; A when pt_lib:is_list(A) -> ok end end),
 ?_test(begin case ast("A.", 0) of B when pt_lib:is_list(B) -> wrong_clause; A when pt_lib:is_variable(A) -> ok end end),
 ?_test(begin case ast("\"A\".", 0) of B when pt_lib:is_variable(B) -> wrong_clause; A when pt_lib:is_string(A) -> ok end end),
 ?_test(begin case ast("{a}.", 0) of B when pt_lib:is_string(B) -> wrong_clause; A when pt_lib:is_tuple(A) -> ok end end),
 ?_test(begin case ast("a() -> 1.", 0) of B when pt_lib:is_tuple(B) -> wrong_clause; A when pt_lib:is_function(A) -> ok end end),
 ?_test(begin case ast("fun(a) -> a end.", 0) of B when pt_lib:is_function(B) -> wrong_clause; A when pt_lib:is_fun(A) -> ok end end),
 ?_test(begin A = "str", case ast("f('@A').", 123) of ast_pattern("f('$B').", _) when pt_lib:is_string(B) -> ok end end),
 ?_test(begin A = {atom, 1, a}, {call, 123, {atom, 123, log}, [{atom, _, a}]} = ast("log($A).", 123) end),
 ?_test(begin A = a, {call, 123, {atom, 123, log}, [{atom, 123, a}]} = ast("log(@A).", 123) end),
 ?_test(begin A = {atom, 1, a}, ast_pattern("log($A).", 123) = {call, 123, {atom, 123, log}, [{atom, 1, a}]} end),
 ?_test(begin A = a, ast_pattern("log(@A).", 123) = {call, 123, {atom, 123, log}, [{atom, 123, a}]} end),
 ?_test(begin ast_pattern("log(...$A...) -> a.", 123) = {function, 123, log, 0, [{clause, 124, [],[],[{atom,125,a}]}]}, A = [] end),
 ?_test(begin A = [], {function, 123, log, 0, [_]} = ast("log(...$A...) -> a.", 123) end),
 ?_test(begin ast_pattern("log() -> ...$A... .", 123) = {function, 123, log, 0, [{clause, 124, [], [], [{aaa}, {bbb}]}]}, A = [{aaa},{bbb}] end),
 ?_test(begin A = [{aaa},{bbb}], {function, 123, log, 0, [{clause, 123, [], [], [{aaa},{bbb}]}]} = ast("log() ->...$A... .", 123) end),
 ?_test(begin ast_pattern("case A of 1 -> 2; ...$A... -> a end.", 1) = ast("case A of 1 -> 2; 3 -> a end.", 1), A = [{integer, 1, 3}] end),
 ?_test(begin ast_pattern("case A of 1 -> 2; 3 -> ...$A... end.", 1) = ast("case A of 1 -> 2; 3 -> a end.", 1), A = [{atom, 1, a}] end),
 ?_test(begin A = [{atom, 1, a}], ast_pattern("case A of 1 -> 2; 3 -> a end.", 1) = ast("case A of 1 -> 2; 3 -> ...$A... end.", 1) end),
 ?_test(begin A = [{integer, 1, 3}], ast_pattern("case A of 1 -> 2; 3 -> a end.", 1) = ast("case A of 1 -> 2; ...$A... -> a end.", 1) end),
 ?_test(begin A = [{aaa},{bbb}], ast("log(...$A...).", 1) = {call, 1, {atom, 1, log}, [{aaa},{bbb}]} end),
 ?_test(begin ast_pattern("log(...$A...).", 1) = {call, 1, {atom, 1, log}, [{aaa},{bbb}]}, A = [{aaa},{bbb}] end),
 ?_test(begin A = [{aaa},{bbb}], ast("mod:log(...$A...).", 1) = {call, 1, {remote, 1, {atom, 1, mod}, {atom, 1, log}}, [{aaa},{bbb}]} end),
 ?_test(begin ast_pattern("mod:log(...$A...).", 1) = {call, 1, {remote, 1, {atom, 1, mod},{atom, 1, log}}, [{aaa},{bbb}]}, A = [{aaa},{bbb}] end),
 ?_test(begin B = {atom, 1, log}, A = [{aaa},{bbb}], ast("$B(...$A...).", 1) = {call, 1, {atom, 1, log}, [{aaa},{bbb}]} end),
 ?_test(begin ast_pattern("$B(...$A...).", 1) = {call, 1, {atom, 1, log}, [{aaa},{bbb}]}, [{aaa},{bbb}] = A, {atom, 1, log} = B end),
 ?_test(begin B = {atom, 1, mod}, A = [{aaa},{bbb}], ast("$B:log(...$A...).", 1) = {call, 1, {remote, 1, {atom, 1, mod}, {atom, 1, log}}, [{aaa},{bbb}]} end),
 ?_test(begin ast_pattern("$B:log(...$A...).", 1) = {call, 1, {remote, 1, {atom, 1, mod},{atom, 1, log}}, [{aaa},{bbb}]}, [{aaa},{bbb}] = A, {atom, 1, mod} = B end),
 ?_test(begin ast_pattern("$A(b) -> a.", 123) = {function, 123, log, 1, [{clause, 124, [{atom, 124,b}],[],[{atom,125,a}]}]}, log = A end),
 ?_test(begin A = log, {function, 123, log, 0, [_]} = ast("$A() -> a.", 123) end),
 ?_test(begin A = 2, {block, 1, A} = ast("begin ...$A... end.", 1) end),
 ?_test(begin ast_pattern("begin ...$A... end.", 1) = {block, 1, 123}, 123 = A end),
 ?_test(begin ast_pattern("fun [...$A...] end.") = {'fun', 3, {clauses, 123}}, 123 = A end),
 ?_test(begin A = 123, {'fun', 3, {clauses, 123}} = ast("fun [...$A...] end." , 3) end),
 ?_test(begin ast_pattern("f [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A end),
 ?_test(begin A = [{clause, 1, [a,b,c], [], [{atom, 1, ok}]}], {function, 1, f, 3, A} = ast("f [...$A...].", 1) end),
 ?_test(begin ast_pattern("$B [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A, f = B end),
 ?_test(begin B = f, A = [{clause, 1, [a,b,c], [], [{atom, 1, ok}]}], {function, 1, f, 3, A} = ast("$B [...$A...].", 1) end),
 ?_test(begin ast_pattern("f/123 [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A end),
 ?_test(begin A = [{clause, 1, [a,b,c,d], [], [{atom, 1, ok}]}], {function, 1, f, 3, A} = ast("f/3 [...$A...].", 1) end),
 ?_test(begin ast_pattern("f/$B [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A, 123 = B end),
 ?_test(begin B = 3, A = [{clause, 1, [a,b,c,d], [], [{atom, 1, ok}]}], {function, 1, f, 3, A} = ast("f/$B [...$A...].", 1) end),
 ?_test(begin ast_pattern("$F/$B [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A, 123 = B, f = F end),
 ?_test(begin F = f, B = 3, A = [{clause, 1, [a,b,c,d], [], [{atom, 1, ok}]}], {function, 1, f, 3, A} = ast("$F/$B [...$A...].", 1) end),
 ?_test(begin ast_pattern("$F/123 [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A, f = F end),
 ?_test(begin F = f, A = [{clause, 1, [a,b,c,d], [], [{atom, 1, ok}]}], {function, 1, f, 123, A} = ast("$F/123 [...$A...].", 1) end),
 ?_test(begin ast_pattern("$_/$_ [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A end),
 ?_test(begin ast_pattern("$_ [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A end),
 ?_test(begin ast_pattern("f/$_ [...$A...].", 1) = {function, 1, f, 123, 456}, 456 = A end),
 ?_test(begin ast_pattern("f [...$_...].", 1) = {function, 1, f, 123, 456} end),
 ?_test(begin ast_pattern("receive [...$A...] after 1 -> b end.") = {'receive', 1, 123, {integer, 1, 1}, [{atom, 1, b}]}, A = 123 end),
 ?_test(begin A = 123, {'receive', 1, 123, {integer, 1, 1}, [{atom, 1, b}]} = ast("receive [...$A...] after 1 -> b end.", 1) end),
 ?_test(begin ast_pattern("receive [...$A...] after $B -> $C end.") = {'receive', 1, 123, 456, [789]}, A = 123, B = 456, C = 789 end),
 ?_test(begin A = 123, B = 456, C = 789, {'receive', 1, 123, 456, [789]} = ast("receive [...$A...] after $B -> $C end.", 1) end),
 ?_test(begin ast_pattern("receive [...$A...] after $B -> ...$C... end.") = {'receive', 1, 123, 456, 789}, A = 123, B = 456, C = 789 end),
 ?_test(begin A = 123, B = 456, C = 789, {'receive', 1, 123, 456, 789} = ast("receive [...$A...] after $B -> ...$C... end.", 1) end),
 ?_test(begin ast_pattern("try ...$A... catch _:_ -> a end.") = {'try', 1, 123, [], [{clause, 1, [{tuple, 1, [{var, 1, '_'}, {var, 1, '_'}, {var, 1, '_'}]}], [], [{atom, 1, a}]}], []}, A = 123 end),
 ?_test(begin A = 123, {'try', 1, 123, [], [{clause, 1, [{tuple, 1, [{var, 1, '_'}, {var, 1, '_'}, {var, 1, '_'}]}], [], [{atom, 1, a}]}], []} = ast("try ...$A... catch _:_ -> a end.", 1) end),
 ?_test(begin A = 123, Clauses = [ast("({A, B, _}) -> a.", 1)], {'try', 1, 123, [], Clauses, []} = ast("try ...$A... catch A:B -> a end.", 1) end),
 ?_test(begin ast_pattern("try ...$A... of [...$C...] catch _:_ -> a end.") = {'try', 1, 123,456, [{clause, 1, [{tuple, 1, [{var, 1, '_'}, {var, 1, '_'}, {var, 1, '_'}]}], [], [{atom, 1, a}]}], []}, A = 123, C =456 end),
 ?_test(begin ast_pattern("try ...$A... catch [...$C...] end.") = {'try', 1, 123, [], 456, []}, A = 123, C =456 end),
 ?_test(begin ast_pattern("try ...$A... catch [...$C...] after ...$B... end.") = {'try', 1, 123, [], 456, 789}, A = 123, C =456, B = 789 end),
 ?_test(begin A = 123, [{atom, 1, a} | 123] = ast("a, ...$A... .", 1) end),
 ?_test(begin ast_pattern("a, ...$A... .") = [{atom, 1, a} | 123], A = 123 end),
 ?_test(begin A = [a], [a, {atom, 1, b}] = ast("...$A..., b.", 1) end),
 ?_test(begin A = [a], [{atom, 1, a} | [a, {atom, 1, b}]] = ast("a, ...$A..., b.", 1) end),
 ?_test(begin A = [a], B = [b], [{atom, 1, a}, a, b] = ast("a, ...$A..., ...$B... .", 1) end),
 ?_test(begin A = [a], B = [b], [{atom, 1, a}, a, {atom, 1, b}, b] = ast("a, ...$A..., b, ...$B... .", 1) end),
 ?_test(begin A = [a], B = [b], [{atom, 1, a}, a, {atom, 1, b}, b, {atom, 1, c}] = ast("a, ...$A..., b, ...$B..., c.", 1) end),
 ?_test(begin A = [a], B = [b], [a, {atom, 1, b}, b, {atom, 1, c}] = ast("...$A..., b, ...$B..., c.", 1) end),
 ?_test(begin ast_pattern("($A, ...$B...) -> $_.") = {clause, 1, [a, b, c], [], [d]}, A = a, B = [b,c] end),
 ?_test(begin A = [a, b], B = c, {clause, 1, [a, b, c], [], [{atom, 1, c}]} = ast("(...$A..., $B) -> c.", 1) end),
 ?_test(begin {clause, 1, [_], [[{atom, 1, b}, {atom, 1, c}], [{atom, 1, d}, {atom, 1, e}]], [_]}  = ast("(a) when b,c; d, e -> f.", 1) end),
 ?_test(begin ast_pattern("() when ...$A... -> ok. ") = {clause, 1, [], 123, [{atom, 1, ok}]}, A = 123 end),
 ?_test(begin ast_pattern("() when ...$A...; ...$B... -> ok. ") = {clause, 1, [], [123, 456], [{atom, 1, ok}]}, A = 123, B = 456 end),
 ?_test(begin ast_pattern("() when $A  -> ok. ") = {clause, 1, [], [[123]], [{atom, 1, ok}]}, A = 123 end),
 ?_test(begin ast_pattern("() when $A, ...$B...; ...$C... -> ok. ") = {clause, 1, [], [[123, 456, 789], 111], [{atom, 1, ok}]}, A = 123, B = [456, 789], C = 111 end),
 ?_test(begin ast_pattern("() when $A; $B  -> ok. ") = {clause, 1, [], [[123], [456]], [{atom, 1, ok}]}, A = 123, B = 456 end),
 ?_test(begin ast_pattern("() when $A, b, c; $B  -> ok. ") = {clause, 1, [], [[123, {atom, 1, b}, {atom, 1, c}], [456]], [{atom, 1, ok}]}, A = 123, B = 456 end),
 ?_test(begin A = 123, {clause, 1, [], 123, [{atom, 1, ok}]} = ast("() when ...$A... -> ok. ", 1) end),
 ?_test(begin A = 123, B = 456, {clause, 1, [], [123, 456], [{atom, 1, ok}]} = ast("() when ...$A...; ...$B... -> ok. ", 1) end),
 ?_test(begin A = 123, {clause, 1, [], [[123]], [{atom, 1, ok}]} = ast("() when $A  -> ok. ", 1) end),
 ?_test(begin A = 123, B = [456, 789], C = 111, {clause, 1, [], [[123, 456, 789], 111], [{atom, 1, ok}]} = ast("() when $A, ...$B...; ...$C... -> ok. ", 1) end),
 ?_test(begin A = 123, B = 456, {clause, 1, [], [[123], [456]], [{atom, 1, ok}]} = ast("() when $A; $B  -> ok. ", 1) end),
 ?_test(begin A = 123, B = 456, {clause, 1, [], [[123, {atom, 1, b}, {atom, 1, c}], [456]], [{atom, 1, ok}]} = ast("() when $A, b, c; $B  -> ok. ", 1) end),
 ?_test(begin [ast_pattern("a.")] = [{atom, 1, a}] end),
 ?_test(begin A = 2, {record, 1, a, [{record_field, 1, A, {integer, 1, 1}}]} = ast("#a{$A = 1}.", 1) end),
 ?_test(begin A = 2, {record, 1, {var, 1, 'V'}, a, [{record_field, 1, A, {integer, 1, 1}}]} = ast("V#a{$A = 1}.", 1) end),
 ?_test(begin A = 2, {record, 1, {var, 1, 'V'}, a, [{record_field, 1, A, {integer, 1, 1}}, {record_field, 1, {atom, 1, a}, {integer, 1, 2}}]}  = ast("V#a{$A = 1, a = 2}.", 1) end),
 ?_test(begin A = 2, B = 3, {record, 1, {var, 1, 'V'}, B, [{record_field, 1, A, {integer, 1, 1}}, {record_field, 1, {atom, 1, a}, {integer, 1, 2}}]}  = ast("V#$B{$A = 1, a = 2}.", 1) end),
 ?_test(begin B = 3, {record, 1, {var, 1, 'V'}, B, [{record_field, 1, {atom, 1, b}, {integer, 1, 1}}, {record_field, 1, {atom, 1, a}, {integer, 1, 2}}]}  = ast("V#$B{b = 1, a = 2}.", 1) end),
 ?_test(begin V = 1, A = 2, B = 3, {record, 1, V, B, [{record_field, 1, A, {integer, 1, 1}}, {record_field, 1, {atom, 1, a}, {integer, 1, 2}}]}  = ast("$V#$B{$A = 1, a = 2}.", 1) end),
 ?_test(begin ast_pattern("$V#$B{$A = 1, a = 2}.", 1) = {record, 1, 1, 3, [{record_field, 1, 2, {integer, 1, 1}}, {record_field, 1, {atom, 1, a}, {integer, 1, 2}}]}, V = 1, A = 2, B = 3 end)
 ].

tst(a, b, c) -> failed;
tst(a, P = ast_pattern("test_fun().", _) = _D, b) -> P;
tst(_, _, _) -> failed.

pt_macro_test_(X) -> X + 1.
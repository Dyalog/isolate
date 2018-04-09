 z←test_syntax dummy;fail;ns;is
⍝ Check all syntax cases
⍝ (see isolate.ynys.decode function)
⍝ a | b      | c       | d    | e
⍝ 0 | array  |         |      |
⍝ 0 | nilad  |         |      |
⍝ 0 | (expr) |         |      |
⍝ 1 | monad  | rarg    |      |
⍝ 2 | larg   | dyad    | rarg |
⍝ 3 | array  | value   |      |
⍝ 4 | array  | indices | axes |
⍝ 5 | array  | indices | axes | value

 {}#.isolate.Config'listen' 0
 {}#.isolate.Config'processors' 4

 {}#.isolate.Reset 0

 ⍝ Create test isolate
 fail←'r←1÷~fail'
 ns←⎕NS''
 ns.fail←0
 ns.mat←3 4⍴⍳12
 ns.⎕FX'r←nil'fail'r←42'
 ns.⎕FX'r←mon x'fail'r←42 x'
 ns.⎕FX'r←x dya y'fail'r←42 x y'
 is←#.ø ns

 ⍝ Test working cases
 is.fail←0
 'is.mat'Fail ns.mat Check is.mat           ⍝ Case 0
 'is.nil'Fail ns.nil Check is.nil
 'is.(21+21)'Fail 42 Check is.(21+21)
 'is.mon'Fail(ns.mon 0)Check is.mon 0      ⍝ Case 1
 'is.dya'Fail(0 ns.dya 0)Check 0 is.dya 0  ⍝ Case 2
 is.newmat←2 2⍴⍳4               ⍝ Case 3
 'is.newmat'Fail is.newmat Check 2 2⍴⍳4
 'is.mat[1;]'Fail ns.mat[1;]Check is.mat[1;]   ⍝ Case 4
 ns.mat[3;]←⍳4⊣is.mat[3;]←⍳4    ⍝ Case 5
 'is.mat (ii)'Fail ns.mat Check is.mat

 :Trap 2
     ns.mat[3;]←is.mat[3;]←⍳4   ⍝ /// This fails
 :Else
     Log'Still not fixed: http://mantis.dyalog.com/view.php?id=11096'
 :EndTrap

 ⍝ Now test failing cases

 :If ##.halt ⍝ global from ExecTest
     is.fail←1 ⍝ Should make all the defined fns crash
     6 'VALUE ERROR' 'nosuchvar'expect'is.nosuchvar'           ⍝ Case 0
     11 'DOMAIN ERROR' 'nil[1] r←1÷~fail'expect'is.nil'
     11 'DOMAIN ERROR' '(1÷0)'expect'is.(1÷0)'
     11 'DOMAIN ERROR' 'mon[1] r←1÷~fail'expect'is.mon 0'      ⍝ Case 1
     11 'DOMAIN ERROR' 'dya[1] r←1÷~fail'expect'0 is.dya 0'    ⍝ Case 2
 ⍝ is.(2+2)←3 ⍝ Can't think of a way to get Case 3 to fail in isolate
     3 'INDEX ERROR' 'mat[...]'expect'+is.mat[4;]'             ⍝ Case 4
     3 'INDEX ERROR' 'mat[...]←...'expect'+is.mat[4;]←2 2⍴3 4' ⍝ Case 5
 :Else
     'unable to test intentional errors due to bug in error trapping'Fail 1
 :EndIf

 z←''

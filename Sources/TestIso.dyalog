:Namespace TestIso

    (⎕IO ⎕ML)←1 1
    assert←{'Assertion failed'⎕SIGNAL(⍵=0)/11}
    
    ∇ msgs expect expr;z;got
    ⍝ Check that the expected error was received
      :Trap 86 ⍝ FUTURE ERROR
          z←+⍎expr ⍝ force future to materialize
          'DID NOT FAIL'⎕SIGNAL 11
      :Else         ⍝ We are expecting a VALUE ERROR
          got←⎕DMX.Message
          :If ((∊⍕¨msgs)~':: ')≢got~': '
              'expected' 'got'⍪⍉⍪msgs got
              ∘
              ⎕SIGNAL something
          :EndIf
      :EndTrap
    ∇

    ∇ z←All
      ⎕←Basic
      ⎕←Syntax
      ⎕←Errors
      ⎕←Callbacks
      #.isolate.Reset 0 ⍝ Leave no trace
    ∇

    ∇ z←Basic;time;delta
     ⍝ Take isolates for a little spin
     
      {}#.isolate.Config'listen' 0
      {}#.isolate.Reset 0
     
      assert 2 4 6 8≡{⍵+⍵}#.IÏ⍳4
     
      time←3⊃⎕AI ⋄ z←⎕DL #.IÏ⍳4
      assert 100>delta←(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
      z←+/z                   ⍝ This should block
      assert 4<delta←(3⊃⎕AI)-time   ⍝ So now we should be >4s
     
⍝ Check that defined functions do not block...
      time←3⊃⎕AI ⋄ z←{⍵ ⍵}⎕DL #.IÏ 1
      assert 100>delta←(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
      z←+/z                   ⍝ This should block
      assert 4<delta←(3⊃⎕AI)-time   ⍝ So now we should me >4s
     
     
      z←'Basic Tests Completed'
    ∇

    ∇ z←Syntax;fail;ns;is
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
      assert ns.mat≡is.mat           ⍝ Case 0
      assert ns.nil≡is.nil
      assert 42≡is.(21+21)
      assert(ns.mon 0)≡is.mon 0      ⍝ Case 1
      assert(0 ns.dya 0)≡0 is.dya 0  ⍝ Case 2
      is.newmat←2 2⍴⍳4               ⍝ Case 3
      assert is.newmat≡2 2⍴⍳4
      assert ns.mat[1;]≡is.mat[1;]   ⍝ Case 4
      ns.mat[3;]←⍳4⊣is.mat[3;]←⍳4    ⍝ Case 5
      assert ns.mat≡is.mat
     
      ⍝ Test indexing cases again with ⎕IO←0 in space
      ⍝ns.⎕IO←0 ⋄ is.⎕IO←0
      ⍝assert is.(mat[2;])≡ns.(mat[2;]) ⍝ Case 4
      ⍝ns.mat[3;]←9 ⋄ is.mat[3;]←9      ⍝ Case 5
      ⍝assert ns.mat≡is.mat
     
      :Trap 2
          ns.mat[3;]←is.mat[3;]←⍳4   ⍝ /// This fails
      :Else
          ⎕←'Still failing:' ⋄ ↑⎕DM
      :EndTrap
     
      ⍝ Now test failing cases
     
      is.fail←1 ⍝ Should make all the defined fns crash
     
      6 'VALUE ERROR' 'nosuchvar'expect'is.nosuchvar'           ⍝ Case 0
      11 'DOMAIN ERROR' 'nil[1] r←1÷~fail'expect'is.nil'
      11 'DOMAIN ERROR' '(1÷0)'expect'is.(1÷0)'
      11 'DOMAIN ERROR' 'mon[1] r←1÷~fail'expect'is.mon 0'      ⍝ Case 1
      11 'DOMAIN ERROR' 'dya[1] r←1÷~fail'expect'0 is.dya 0'    ⍝ Case 2
      ⍝ is.(2+2)←3 ⍝ Can't think of a way to get Case 3 to fail in isolate
      3 'INDEX ERROR' 'mat[...]'expect'+is.mat[4;]'             ⍝ Case 4
      3 'INDEX ERROR' 'mat[...]←...'expect'+is.mat[4;]←2 2⍴3 4' ⍝ Case 5
     
      z←'Syntax Tests Completed'
    ∇

    ∇ z←Errors;is;result
     ⍝ More advanced error handling
     
      {}#.isolate.Config'listen' 1
      {}#.isolate.Config'onerror' 'signal'
      {}#.isolate.Reset 0
     
      assert 5=≢result←{1 2 3÷⍵}#.IÏ 1 2(3 4)(5 6)0
      assert(2⊃result)≡0.5 1 1.5
      5 'LENGTH ERROR' '{1 2 3÷⍵}'expect'3⊃result'
      5 'LENGTH ERROR' '{1 2 3÷⍵}'expect'4⊃result'
      11 'DOMAIN ERROR' '{1 2 3÷⍵}'expect'5⊃result'
     
      is←#.ø''
      ⎕EX'NNNN'
      :Trap 11 ⋄ assert ⎕NULL≡is.##.NNNN ⍝ This should DOMAIN ERROR
      :EndTrap
     
      6 'VALUE ERROR IN CALLBACK' 'NNNN'expect'is.(##.NNNN)'
     
      NNNN←42
      assert 42=is.(##.TestIso.NNNN) ⍝ This should work
      ⎕EX'NNNN'
     
      z←'Error Tests Completed'
    ∇

    ∇ z←Callbacks
     ⍝ Test ability to perform callbacks
     
      {}#.isolate.Config'listen' 1
      {}#.isolate.Config'onError' 'signal'
      #.isolate.Reset 0
     
      COUNTER←1
     
      is←#.ø''
      6 'VALUE ERROR IN CALLBACK' 'nosuchvar'expect'is.(##.nosuchvar)'
      assert 2 3 4 5≡{##.TestIso.COUNTER+⍵}#.IÏ⍳4
      z←'Callback Tests Completed'
    ∇

:EndNamespace
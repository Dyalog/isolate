:Namespace TestIso

    (⎕IO ⎕ML)←1 1
    assert←{'Assertion failed'⎕SIGNAL(⍵=0)/11} 
    runtime←1
    dup←{⍵ ⍵}
    
    ∇ msgs expect expr;z;got
    ⍝ Check that the expected error was received
      :Trap 86 ⍝ FUTURE ERROR
          z←+⍎expr ⍝ force future to materialize
          'DID NOT FAIL'⎕SIGNAL 11
      :Else        ⍝ We are expecting a VALUE ERROR
          got←⎕DMX.Message
          :If ((∊⍕¨msgs)~': '){⍺≢(⍴⍺)↑⍵}got~': '
              'expected' 'got'⍪⍉⍪msgs got
              ∘
              ⎕SIGNAL something
          :EndIf
      :EndTrap
    ∇

    ∇ z←All n;c;slow
      c←0
      slow←⍬
      ⎕←'runtime'runtime
     
      :While c<n
          c←c+1
          ⎕←''
          ⎕←'Isolate test run #',⍕c
          {}#.isolate.Config'runtime'runtime
          ⎕←Basic
          ⎕←Syntax
          ⎕←Errors
          ⎕←Callbacks
          #.isolate.Reset 0 ⍝ Leave no trace
      :EndWhile
      ⎕←(⍕n),' isolate tests completed'
      :If 0≠≢slow
          ⎕←'NB: ',(⍕≢slow),' slow starts - in ms: ',⍕slow[⍒slow]
      :EndIf
    ∇

    ∇ z←Basic;time;delta;is;ns
     ⍝ Take isolates for a little spin
     
      {}#.isolate.Config'listen' 0
      {}#.isolate.Reset 0
     
      assert 2 4 6 8≡{⍵+⍵}#.IÏ⍳4
     
      time←3⊃⎕AI ⋄ z←⎕DL #.IÏ⍳4
      :If 100<delta←(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
          slow,←delta
          ⎕←'*** WARNING: First set of futures took ',(⍕delta),' ms to materialise.'
      :EndIf
      z←+/z                   ⍝ This should block
      assert 4<delta←(3⊃⎕AI)-time   ⍝ So now we should be >4s
     
     ⍝ Check that defined functions do not block...
      time←3⊃⎕AI ⋄ z←{⍵ ⍵}⎕DL #.IÏ 1
      assert 100>delta←(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
      z←+/z                   ⍝ This should block
      assert 4<delta←(3⊃⎕AI)-time   ⍝ So now we should me >4s
     
     ⍝ Check isolate creation options
      data←42 ⍝ NB must not be localised
      ns←⎕NS'dup' 'data'
      is←#.ø ns           ⍝ Clone namespace
      assert(42 42)≡is.(dup data)
     
      is←#.ø'TestIso.dup' 'TestIso.data' ⍝ Create is from name list
      assert(42 42)≡is.(dup data)
     
      is←#.ø(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'\ws\dfns.dws' ⍝ copy ws
      assert 12≡≢is.queens 8
     
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

    ∇ z←Errors;is;result;x
     ⍝ More advanced error handling
     
      {}#.isolate.Config'listen' 1
      {}#.isolate.Config'onerror' 'signal'
      {}#.isolate.Reset 0
     
      assert 5=≢result←{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}#.IÏ 1 2(3 4)(5 6)0
      ⎕DL 4
      x←4 5⍴#.isolate.(Values,Available,Failed,Running)'result'
      assert((1 2 3)(0.5 1 1.5)⎕NULL ⎕NULL ⎕NULL)≡x[1;] ⍝ Values
      assert 1 1 0 0 0≡x[2;] ⍝ Available
      assert 0 0 1 0 1≡x[3;] ⍝ Failed
      assert 0 0 0 1 0≡x[4;] ⍝ Still running
     
      :Repeat ⋄ ⎕DL 0.1 ⋄ :Until ~∨/#.isolate.Running'result'
      5 'LENGTH ERROR' '{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}'expect'3⊃result'
      5 'LENGTH ERROR' '{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}'expect'4⊃result'
      11 'DOMAIN ERROR' '{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}'expect'5⊃result'
     
      is←#.ø''
      ⎕EX'NNNN'
      :Trap 11 ⋄ assert ⎕NULL≡is.##.NNNN ⍝ This should DOMAIN ERROR
      :EndTrap
     
      6 'VALUE ERROR IN CALLBACK'expect'is.(##.NNNN)'
     
      NNNN←42
      assert 42=is.(##.TestIso.NNNN) ⍝ This should work
      ⎕EX'NNNN'
     
      z←'Error Tests Completed'
    ∇

    ∇ z←Callbacks;counts;is
     ⍝ Test ability to perform callbacks
     
      {}#.isolate.Config'listen' 1
      {}#.isolate.Config'onError' 'signal'
      #.isolate.Reset 0
     
      COUNTER←1
     
      is←#.ø''
      6 'VALUE ERROR IN CALLBACK' 'nosuchvar'expect'is.(##.nosuchvar)'
      counts←{##.TestIso.COUNTER+⍵}#.IÏ⍳4
      assert 2 3 4 5≡counts
      z←'Callback Tests Completed'
    ∇

:EndNamespace

:Namespace TestIso

    (⎕IO ⎕ML)←1 1
    assert←{'Assertion failed'⎕SIGNAL(⍵=0)/11}

    ∇ z←Run
      ⎕←Basic
      ⎕←Errors
      ⎕←Callbacks
      #.isolate.Reset 0 ⍝ Leave no trace
    ∇

    ∇ z←Basic
     ⍝ Take isolates for a little spin
     
      #.isolate.Config'listen' 0
      #.isolate.Reset 0
     
      assert 2 4 6 8≡{⍵+⍵}#.IÏ⍳4
     
      time←3⊃⎕AI ⋄ z←⎕DL #.IÏ⍳4
      assert 100>(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
      z←+/z                   ⍝ This should block
      assert 4<(3⊃⎕AI)-time   ⍝ So now we should me >4s
     
      z←'Basic Tests Completed'
    ∇
 
    ∇ z←Errors;is
     ⍝ Test error handling
     
      #.isolate.Config'listen' 1
      #.isolate.Config'onError' 'signal'
      #.isolate.Reset 0
     
      ⍝ ↓↓↓ Should use ≢
      assert 5=⍴z←{1 2 3÷⍵}#.IÏ 1 2(3 4)(5 6)0
      assert(2⊃z)≡0.5 1 1.5
      :Trap 6 ⋄ assert 0=≢3⊃z ⍝ This should fail
      :Else ⋄ assert(2 2⍴1 11 2 5)≡{⍵[⍋⍵;]}2(↑⍤1)#.isolate.LastError''
      :EndTrap
     
      is←#.ø''
      ⎕EX'NNNN'
      :Trap 11 ⋄ assert ⎕NULL≡is.##.NNNN ⍝ This should DOMAIN ERROR
      :EndTrap
     
      :Trap 6 ⋄ assert 0=is.(##.NNNN) ⍝ This should fail
      :Else ⋄ assert(1 2⍴1 6)≡2(↑⍤1)#.isolate.LastError''
      :EndTrap
     
      NNNN←42
      assert 42=is.(##.TestIso.NNNN) ⍝ This should work
      ⎕EX'NNNN'
     
      z←'Error Tests Completed'
    ∇

    ∇ z←Callbacks
     ⍝ Test ability to perform callbacks
     
      #.isolate.Config'listen' 1
      #.isolate.Reset 0
     
      COUNTER←1
     
      assert 2 3 4 5≡{##.TestIso.COUNTER+⍵}#.IÏ⍳4
      z←'Callback Tests Completed'
    ∇

:EndNamespace
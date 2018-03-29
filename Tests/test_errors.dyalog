 z←test_errors dummy;x;result;is

 ⍝ test more advanced error handling

 {}#.isolate.Config 'onerror' 'signal' ⍝ paranoia: should be the default
 {}#.isolate.Reset 0

 'IÏ with one error' Fail 5 Check ≢result←{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}#.IÏ 1 2(3 4)(5 6)0
 ⎕DL 4
 x←4 5⍴#.isolate.(Values,Available,Failed,Running)'result'
 'Test of isolate.Values'    Fail ((1 2 3)(0.5 1 1.5)⎕NULL ⎕NULL ⎕NULL) Check x[1;]
 'Test of isolate.Available' Fail 1 1 0 0 0 Check x[2;]
 'Test of isolate.Failed'    Fail 0 0 1 0 1 Check x[3;]
  'Test of isolate.Running'  Fail 0 0 0 1 0 Check x[4;]

 :Repeat ⋄ ⎕DL 0.1 ⋄ :Until ~∨/#.isolate.Running'result'
 5 'LENGTH ERROR' '{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}'expect'3⊃result'
 5 'LENGTH ERROR' '{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}'expect'4⊃result'
 11 'DOMAIN ERROR' '{z←⎕DL⊃⍵ ⋄ 1 2 3÷⍵}'expect'5⊃result'

 {}#.isolate.Reset 0

 z←''

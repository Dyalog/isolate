 z←test_callbacks dummy;counts;is
⍝ test that calls back to the parent workspace are working

 {}#.isolate.Config'listen' 1
 {}#.isolate.Reset 0

 is←#.ø''

 :Trap 11 ⋄ 'is.##.NNNN' Fail ⎕NULL Check is.##.COUNTER ⍝ This should DOMAIN ERROR
 :EndTrap

 #.COUNTER←1

 6 'VALUE ERROR IN CALLBACK' 'nosuchvar'expect'is.(##.nosuchvar)'

 counts←⊃¨{##.COUNTER+⍵}#.IÏ⍳4
 'Callback counter test' Fail 2 3 4 5 Check counts

 #.⎕EX 'COUNTER'
 {}#.isolate.Config'listen' 0
 {}#.isolate.Reset 0

 z←''

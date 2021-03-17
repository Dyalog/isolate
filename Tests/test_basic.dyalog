 z←test_basic dummy;time;delta;is;ns;test;dfns;double;rtack;n2
 ⍝ Take futures and isolates for a little spin

 rtack←⍎⎕UCS 8866 ⍝ // work aroung bug in Log
 {}#.isolate.Config'listen' 0
 {}#.isolate.Config'processors' 4

 {}#.isolate.Reset 0

 test←'Basic IÏ test'
 double←{⍵+⍵}#.IÏ⍳4

 ⎕DL 0.5
 :If 2 4 6 8≢double
 :AndIf 2 4 6 8≡⊃¨double
     Log'*** WARNING: Still not fixed: http://mantis.dyalog.com/view.php?id=15672'
 :EndIf

 double←⊃¨double
 test Fail 2 4 6 8 Check double ⍝ Remove the above :If clause when the bug is fixed

 time←3⊃⎕AI ⋄ z←⎕DL #.IÏ 4⍴1
 :If 100<delta←(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
     Log'*** WARNING: Futures took ',(⍕delta),' ms to materialise.'
 :EndIf
 z←+/z ⍝ will block
 '⎕DL IÏ 4⍴1 ran in less than 1 second'Fail 1000>delta←(3⊃⎕AI)-time

 ⍝ Check that passing argument to defined functions does not block...
 time←3⊃⎕AI ⋄ z←{⍵ ⍵}⎕DL #.IÏ 1
 :If 100<delta←(3⊃⎕AI)-time ⍝ Getting futures back should take <100ms
     Log'*** WARNING: Futures took ',(⍕delta),' ms to materialise.'
 :EndIf
 z←+/z                         ⍝ This should block
 '+/{⍵ ⍵}⎕DL IÏ 1 ran in less than 1 second'Fail 1000>delta←(3⊃⎕AI)-time

 n2←(2×1111⌶⍬)

 :Trap 0
     z←⎕NC ll.Each n2⍴⊂'...'
     'll.Each'Fail(n2⍴¯1)Check z
 :Else
     ((⊃⎕DM),' in ll.Each: ')Fail 0
 :EndTrap

 ⍝ Check isolate creation options
 #.data←42 ⍝ NB must not be localised
 #.dup←{⍵ ⍵}

 ns←#.⎕NS'dup' 'data'
 is←#.ø ns         ⍝ Clone namespace
 'Clone isolate from NS'Fail(3 2)Check is.⎕NC↑'dup' 'data'

 is←#.ø'dup' 'data' ⍝ Create is from name list
 'Create isolate from namelist'Fail(3 2)Check is.⎕NC↑'dup' 'data'
 #.⎕EX'dup' 'data'

 'Unable to find dfns.dws'Fail 0=≢dfns←FindWs'dfns.dws'
 is←#.ø dfns
 'Create isolate from dfns.dws'Fail(,3)Check is.⎕NC'queens'

 z←''

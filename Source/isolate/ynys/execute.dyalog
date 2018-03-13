 r←execute(name data);z;n;space;zz;wsid;⎕TRAP
 :If name≡''
     :Select data
     :Case 'identify' ⍝ return isoid
         r←0(⊃1⊃⎕VFI+##.RPCServer.GetEnv'isoid')
     :Else
         r←11('ISOLATE: Unknown command'data)
     :EndSelect
 :Else
     :Trap 6 ⋄ space←#.⍎name
     :Else ⍝ Seems the isolate ns was not created
         r←6('Isolate initialization failed - check workspace name' '' '^')
         →0
     :EndTrap

     :Hold 'ISO_',name
         :If {0::0 ⋄ ##.onerror≡⍵}'debug'
             wsid←⎕WSID
             ⎕TRAP←0 'E' '⎕WSID←''ISOLATE - '',{(100⌊⍴⍵)↑⍵},⍕2↑⎕DM ⋄ ⎕←↑⎕DM ⋄ ⎕←''To resume:'',(⎕UCS 13),''      →⎕LC'''
             r←space decode 5↑data
             ⎕WSID←wsid ⋄ z←{0::0 ⋄ 2022⌶⍵}0 ⍝ Flush session caption
         :Else
             r←space decode 5↑data
         :EndIf

         :If 0=⎕NC'session' ⍝ In the isolate
             :Trap 6
                 z←+r ⍝ Block on futures here to provoke (and trap) the VALUE ERROR
             :Else
                 :If 2=⎕NC n←name,'error'
                     r←⍎n ⋄ ⎕EX n
                     (1 0⊃r),←' IN CALLBACK'
                 :Else
                     r←6('VALUE ERROR: Callback failed'(1⊃data)'^')
                 :EndIf
             :EndTrap
             :If (⎕NC⊂'zz'⊣zz←1⊃r)∊9.2 9.4 9.5
                 r←11('ISOLATE ERROR: Result cannot be returned from isolate' '')
             :EndIf

         :EndIf
         r←cleanDM r
     :EndHold
 :EndIf
⍝ this is the function called by RPCServer.Process
⍝ ⍵     name data
⍝ data  list created by encode below.
⍝ ←     result or assignment of decoded ⍵

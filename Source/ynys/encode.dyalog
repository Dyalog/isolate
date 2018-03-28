 encode←{⍺←⊢
     la←(⍵≡⍺ ⍵)↓⊂⍺⊣0  ⍝ enclosed if supplied
     ra←(⊢⍴⍨1~⍨⍴)3↓⍵  ⍝  - empty if not
     (x nc s)←3⍴⍵
     pargs←{⍺←⊢       ⍝ analyse [PropertyArguments]
         ra←⍵
         9≠⎕NC'ra':ra                  ⍝ not a space
         nms←'Indexers' 'IndexersSpecified' 'IndexOrigin' 'NewValue'
         3>+/nms/⍨←∧\2=⌊ra.⎕NC nms:ra  ⍝ not a [PropertyArgs]
         n←ra.⍎¨nms
         (0⊃n)←(-2⊃n)+(0,1⊃n)/0,0⊃n     ⍝ 0+indices sans ⎕NULLs
         (1⊃n)←{⍵/⍳⍴⍵}1⊃n               ⍝ 0+axes
         ((⍴n)↑1 1 0 1)/n
     }
     args←la,(⊂x),pargs ra
     code←nc{6|0(3 2)(3 3)(2 2)(2 3)(2 4)⍳⊂⍺,⍵}⍴args
     code,args
⍝ called in ##.proxyClone.iEvaluate - here because its inverse has to be
⍝ ⍺ larg to iEvaluate - larg to isolate.dyad
⍝ ⍵ rarg to iEvaluate - name class syntax [rarg | PropertyArguments]
⍝   creates list that encodes syntax and includes arguments
 }

:namespace RPCIsolate
⍝ ## ←→ #.isolate.ynys

(⎕IO ⎕ML)←0 0

 decode←{⍺←⊢
     where←⍺
     x←where.⍎
     (a b c d e)←5↑⍵
     (a0 a1 a2 a3 a4 a5)←a=0 1 2 3 4 5
     a0:x b
     a1:(x b)c
     a2:b(x c)d
     a3:c⊢b{x ⍺,'←⍵'}c
     (i j)←c d+where.⎕IO
     a4:⍎'i(j where.{⊢⍺⌷[⍺⍺]',b,'})0'
     a5:⍎'i(j where.{⊢(⍺⌷[⍺⍺]',b,')←⍵})e'
⍝ ⍺ target space
⍝ ⍵ encoded list
⍝   decode list and execute requisite syntax in target.
⍝ see #.isolate.notes
 }

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
         ((⍴n)↑1 1 0)/n
     }
     args←la,(⊂x),pargs ra
     code←nc{6|0(3 2)(3 3)(2 2)(2 3)(2 4)⍳⊂⍺,⍵}⍴args
     code,args
⍝ called in ##.proxySpace.iEvaluate - here because its inverse has to be
⍝ ⍺ larg to iEvaluate - larg to isolate.dyad
⍝ ⍵ rarg to iEvaluate - name class syntax [rarg | PropertyArguments]
⍝   creates list that encodes syntax and includes arguments
⍝ see #.isolate.notes
 }

 execute←{⍺←⊢
     (name data)←⍵
     space←#.⍎name
     space decode data
⍝ this is the function called by RPCServer.Run
⍝ ⍵     name data
⍝ data  list created by encode below.
⍝ ←     result or assignment of decoded ⍵
 }

 receive←{⍺←⊢
     (source root id)←⍵
     name←id.chrid
     root←#.⎕NS root
     root.iSpace←#
     id.(port←home)                     ⍝ change these -
     id.(chrid←'Iso',⍕1+numid)          ⍝ - for callback -
     id.tgt←,'#'                        ⍝ - to home ws
     root.iD←id
     iso←root.⎕NS(⍴⍴source)⊃source''           ⍝ clone of source
     z←iso.{6::0 ⋄ z←{}⎕CY ⍵}⍣(≡source)⊢source ⍝ or copy if ws
     z←iso.{6::0 ⋄ z←{}(↑'⎕io' '⎕ml')⎕CY ⍵}⍣(≡source)⊢source
     z←#.DRC.Clt id.(chrid orig port)   ⍝ orig=host if local
     z←name{#.⍎⍺,'←⍵'}iso
     ⊢z←1(700⌶)root
 }

:endnamespace

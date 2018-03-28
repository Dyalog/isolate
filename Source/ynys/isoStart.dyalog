 isoStart←{⍺←⊢
     ##.onerror←##.RPCServer.GetEnv'onerror'
     protocol←##.RPCServer.GetEnv'protocol'
     iso←'isolate'
     parm←##.RPCServer.GetEnv iso
     parm≢iso: Description
     msgbox←{
         last←{⍺ ⍺⍺[(≢⍴⍵)-~⎕IO]⍵}
         ctr←{(⌊0.5×⍺-⍨⊢/⍴⍵)⌽⍺↑last ⍵}
         'W'=⊃2↓'#'⎕WG'APLVersion':⎕DQ'msg'⎕WC'MsgBox'⍺ ⍵'Error'
         {⎕SM←2 7⍴⍺ 1 1 0 0 0 2059,⍵ 3 1 0 0 0 2059 ⋄ (⎕SM←0⌿⎕SM)⊢''⊣⎕SR 1
         }/⊃¨ctr/¨(2↑⍉⍪⍺){(⌈/≢∘⍉¨⍺ ⍵){⍺ ⍵}¨⍺ ⍵}↑⍵
     }
     f00←{
         'R'∊⊃⊢/'#'⎕WG'APLVersion':{
             Caption←'Isolate Startup Failure'
             Text←⎕DM
             Caption msgbox Text
         }''
         (⊃⍬⍴⎕DMX.DM)⎕SIGNAL ⎕DMX.EN
     }
     ⎕TRAP←0 'C' 'f00⍬'

     ##.DRC←⎕THIS.DRC←getDRC #
     ##.RPCServer.SendProgress←0 ⍝ Do not send progress reports
     ##.RPCServer.Protocol←protocol
     ##.RPCServer.Boot
⍝ start as process if loaded with "isolate=isolate" in commandline
 }

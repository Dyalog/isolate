 checkLocalServer w;z
      ⍝ take opportunity to check listener is up
 :If options.listen
     :If 2≠⎕NC'session.listeningtid'
     :OrIf session.listeningtid(~∊)⎕TNUMS
         ⎕←'ISOLATE: Callback server restarted'
         onerror←options.onerror
         z←localServer 1
     :EndIf
 :EndIf

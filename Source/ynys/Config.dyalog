 Config←{⍺←⊢
     newSession'':{              ⍝ else Init has already run
         0::(⊃⎕DMX.DM)⎕SIGNAL ⎕DMX.EN
         setDefaults ⍵
     }⍵
     trapErr''::signal''
     getSet ⍵

⍝ set or query single option
⍝ ⍵         '' | name | name value
⍝ name      one of params defined in setDefaults
⍝ value     new value for param
⍝ ←         ⍵:''            : table of all names and values
⍝           ⍵:name          : value
⍝           ⍵:name value    : old value having set new in param
 }

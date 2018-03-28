 whoami←{⍺←⊢
     'localhost'
     (W wc wa L lc la A ac aa)←messages'⍝- '
     (adr cfg)←(W L A⍳⊂3⍴⊃#.⎕WG'APLVersion')⊃(wa wc)(la lc)(aa ac)
     ⊃{(⍵≠' ')⊂⍵⊣⎕ML←3}(1↓⍳∘':'↓⊢)⊃{⍵⌿⍨∨/adr⍷minuscule↑⍵}⎕CMD cfg
⍝- Win
⍝- ipconfig
⍝- ipv4 address

⍝- Lin
⍝- /sbin/ifconfig
⍝- inet addr

⍝- AIX
⍝- ifconfig
⍝- inet addr
 }

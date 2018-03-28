 r←Build;file;ver;src;t;version;rev;path;root;buildver
⍝ As part of running isolate.dbuild, tweak the workspace a bit:
⍝    Build cover-functions in # and #.isolate (see function "BuildCovers")
⍝    Insert isolate.Version to include GIT version numbers

 r←''
 version←'1.1' ⍝ base version
 root←⌽{(⌊/⍵⍳'/\')↓⍵}⌽⎕WSID

 buildver←'16.0' ⍝ Use v16.0 or later to build
 :If buildver≢(≢buildver)↑2⊃'.'⎕WG'APLVersion'
     ⎕←'*** WARNING - Production builds should be run using Dyalog ',buildver,' ***'
 :EndIf

 :If 0=⍴ver←⍕{0::'' ⋄ ⎕CMD'git -C "',⍵,'" rev-list HEAD --count'}root
 :OrIf (,1)≢1⊃⎕VFI ver
     ⎕←'NB: Unable to get GIT revision information!'
     ver←'0'
 :Else
     ver←ver~' '
 :EndIf

 ver←version,'.',⍕2⊃⎕VFI⍕ver ⍝ Join base version and git push count
 ⎕←'isolate.Version set to:'
 ⎕←isolate.Version←'Version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS

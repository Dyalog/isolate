 Build;version;db;root;warn;ver;vn;glyph;name;nr;date
⍝ As part of running isolate.dbuild, tweak the workspace a bit:
⍝    Build cover-functions in #.isolate
⍝    Insert isolate.Version to include GIT last commit date
 version←'1.5' ⍝ base version - update this whenever there is a version bump
 db←1⊃⎕RSI ⍝ Ref to DyalogBuild environment
 root←db.path
 warn←''
 #.isolate.⎕EX'APLProcess' ⍝ make sure any APLProcess loaded from isolate is expunged
 ⎕SE.SALT.Load'[DYALOG]Library/Core/APLProcess -target=#.isolate' ⍝ load the "official" APLProcess
⍝ check if APLProcess.Version>2.2.7 and signal error if not...
 ver←2⊃#.isolate.APLProcess.Version
 vn←2⊃'.'⎕VFI ver
 :If vn{1↑⊃≥/(<\⍺≠⍵)∘/¨⍺ ⍵}2 2 8 ⍝ minimum version should be 2.2.8
     ('APLProcess.Version should be 2.2.8 or greater, it is currently: ',ver)⎕SIGNAL 11
 :EndIf
 ⍝ Build cover functions with typeable names in #.isolate
 :For glyph name :In ('II' 'll')('IIÐ' 'llKey')('IIö' 'llRank')('IÏ' 'llEach')('o_II' 'llOuter')
     :If 0∊⍴nr←#.⎕NR glyph
         11 ⎕SIGNAL⍨'isolate Build: Could not find #.',glyph
     :EndIf
     nr[1]←⊂name,'←'((¯1∘+⍳⍨)↓⊢)1⊃nr
     :If 0=1↑0⍴#.isolate.⎕FX nr
         11 ⎕SIGNAL⍨'Unable to define cover function #.isolate.',name
     :EndIf
 :EndFor
 :Trap 0
     :If 0≠⍴date←⍕{0::'' ⋄ ⊃⎕CMD'git -C "',⍵,'" log -1 --format=%ci'}root
     :OrIf 0≠⍴date←⍕{0::'' ⋄ ⊃⎕CMD'cd "',⍵,'" && svn info | sed -n "s/^Last Changed Date: \\(.*\\) (.*/\\1/p"'}root
         date←' (',date,')'
     :Else
        ⍝ MBaas: signalling an error means build-failure -> only do that when we build for production, but be tolerant when we build for tests
         :If 2=db.⎕NC'prod'
         :AndIf db.prod
         :AndIf 0<≢2 ⎕NQ #'GetEnvironment' 'NODATENEEDED'   ⍝ NODATENEEDED indicates that the production build does not need to have a date (we use this when running tests)
             'isolate Build: Unable to get GIT last commit date - isolate. Version not set!'⎕SIGNAL 11
         :Else
             warn←'isolate Build: Unable to get GIT last commit date ! '
             date←''
         :EndIf
     :EndIf
 :Else
     warn←'isolate Build: trapped error getting last commit date:',(⎕JSON ⎕OPT'Compact' 0)⎕DMX
     date←''
 :EndTrap
 ver←version,date ⍝ Join base version and git last commit date
 isolate.Version←'Version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS
 :If ~0∊⍴warn ⋄ db.Log warn ⋄ :EndIf
 db.Log'isolate.Version set to: ',isolate.Version

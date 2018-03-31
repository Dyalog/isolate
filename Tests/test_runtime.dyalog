 z←test_runtime dummy;fail;ns;is;n;curex;rt;ver;curver;old
⍝ Test all possible settings of the "runtime" option
⍝ 0       = use development environment
⍝ 1       = use runtime interpreter
⍝ charvec = load named executable

 old←#.isolate.Config'processors' 1

 curex←#.isolate.APLProcess.GetCurrentExecutable
 curver←4⊃'.'⎕WG'APLVersion'

 :For (rt ver) :In (0 'Development')(1 'Runtime')(curex curver)

     {}#.isolate.Config'runtime'rt
     {}#.isolate.Reset 0
     is←#.isolate.New''
     ('runtime=',⍕rt)Fail ver Check is.(4⊃'.'⎕WG'APLVersion')
     ⎕EX'is'

 :EndFor

 {}#.isolate.Config'processors'old
 {}#.isolate.Config'runtime'1
 {}#.isolate.Reset 0

 z←''

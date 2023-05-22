 setDefaults←{⍺←⊢
     here←⎕THIS
     new←0=here.⎕NC⊂'options'                      ⍝ set defaults only once
     z←{
         spaces←here.(types options domains)←here.⎕NS¨⍬ ⍬ ⍬
         tod←{(2⍴⍵),⊂1↓⍵}                          ⍝ type: Str Bool Int Ref
     ⍝ ensure all param names are minuscule as arg to Config is converted thus.
     ⍝        spaces.param← tod 'S' 'Default' 'and' 'the' 'Rest'
         spaces.debug←tod'B' 0                     ⍝ cut back on error
         spaces.drc←tod'R'#                        ⍝ copy into # if # and missing
         spaces.listen←tod'B' 0                    ⍝ can isolate call back to ws
         spaces.onerror←tod'S' 'signal' 'debug' 'return'
         spaces.processors←tod'I'(processors ⍬)    ⍝ no. processors (fn ignores ⍵)
         spaces.processes←tod'I' 1                 ⍝ per processor
         spaces.isolates←tod'I' 99                 ⍝ per process
         spaces.homeport←tod'I' 7051               ⍝ first port to attempt to use
         spaces.homeportmax←tod'I' 7151            ⍝ highest port allowed
         spaces.runtime←tod'A' 1                   ⍝ use runtime version
         spaces.protocol←tod'S' 'IPv4' 'IPv6' 'IP' ⍝ default to IPv4
         spaces.maxws←tod'S'(##.RPCServer.GetEnv'MAXWS')
         spaces.status←tod'S' 'client' 'server'    ⍝ set as 'server' by StartServer
         spaces.workspace←tod'S'(getDefaultWS'isolate.dws') ⍝ load current ws for remotes?
         spaces.rideinit←tod'S' ''                 ⍝ RIDE_INIT for APLProcess
         spaces.outfile←tod'S' ''                  ⍝ log file prefix for APLProcess
         spaces.workdir←tod'S' ''                  ⍝ working directory for APLProcess
         spaces.cmdargs←tod'S' 'ENABLE_CEF=0'      ⍝ add to command line
         1:1
     }⍣new⊢0
     0::(⊃⍬⍴⎕DMX.DM)⎕SIGNAL ⎕DMX.EN
     ⊢getSet ⍵                                     ⍝ this where Config called prior Init
     ⍝ called by Config before Init runs and by Init when it does.
⍝ set default options and permit user changes
⍝ but leave Init to apply them.
 }

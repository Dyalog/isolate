:namespace ynys
⍝ ## ←→ #.isolate

    (⎕IO ⎕ML)←0 1

    tracelog←{⎕←((1⊃⎕SI),'[',(⍕1⊃⎕LC),']') ⍵}
    ⍝tracelog←{}        ⍝ uncomment this line to disable all logging

    ∇ r←AddServer w;msg;addr;ports;z;ss;id;pclts;m;old;local
      msg←messages'⍝- '
      :If 'server'≡Config'status' ⋄ r←0⊃msg ⋄ :Return ⋄ :EndIf
      :If local←''≡w
          addr←whoami''
      :Else
          :If ''⍬≢0/¨w ⋄ r←1⊃msg ⋄ :Return ⋄ :EndIf
          (addr ports)←,¨w
          :If {1∊∊∘∊⍨⍵⊣⎕ML←0}addr ports ⋄ r←2⊃msg ⋄ :Return ⋄ :EndIf
      :EndIf
      z←Config'status' 'client'
      z←Init 0
      ss←session
      :If (⊂addr)∊ss.procs[;2] ⋄ r←(3⊃msg),' ',addr ⋄ :Return ⋄ :EndIf
      :If local
          ss.procs⍪←ss InitProcesses options
      :Else
          id←(⍳≢ports)+1+0⌈⌈/⊣/ss.procs
          ss.retry_limit←2⊣old←ss.retry_limit
          pclts←id InitConnections addr ports ¯1
          ss.retry_limit←old
          :If m←0∊≢¨pclts ⋄ r←(4⊃msg),' ',addr,': ',⍕m/ports ⋄ :Return ⋄ :EndIf
          ss.procs⍪←id,0,(⊂addr),ports,⍪pclts
      :EndIf
      r←State''
⍝- Session already started as server
⍝- Argument must be 'ip-address' (ip-ports)
⍝- IP-address nor IP-ports can be empty
⍝- Already added:
⍝- Unable to connect to
    ∇

    ∇ r←DRCClt args;count
      ⍝ Create a DRC Client, looping a bit
     
      {}DRC.Close⊃args ⍝ Paranoia, the bug is somewhere else, sorry!
      count←0
      :While 0≠⊃r←DRC.Clt args ⍝ Cannot connect
          :If 1111=⊃r
              {}⎕DL session.retry_interval×count+←1 ⍝ longer wait each time
          :Else
              ('ISOLATE: Unable to connect to isolate process: ',⍕args)⎕SIGNAL 11
          :EndIf
      :Until count≥session.retry_limit
    ∇

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

    ∇ checkLocalServer w;z
      ⍝ take opportunity to check listener is up
      :If options.listen
          :If 2≠⎕NC'session.listeningtid'
          :OrIf session.listeningtid(~∊)⎕TNUMS
              ⎕←'ISOLATE: Callback server restarted'
              onerror←options.onerror
              z←localServer 1
          :EndIf
      :EndIf
    ∇

    ∇ {r}←Init local;here;z;ss;op;maxws;ws;rt;iso;ports;pids;pclts
      r←⎕THIS.⎕IO←0
      :If newSession''
          here.iSpace←here←⎕THIS
          z←here.(proxyClone←⎕NS'').⎕FX¨proxySpace.(⎕CR¨↓⎕NL 3)
          z←here.proxyClone.⎕FX iSpace.⎕CR'tracelog'
          ss←here.session←⎕NS''
          z←setDefaults''
          op←options
          z←getSet'debug'op.debug                 ⍝ on or off
          :Trap trapErr''
              ##.DRC←here.DRC←getDRC op.drc
              z←DRC.Init ⍬
              z←DRC.SetProp'.' 'Protocol'(op.protocol)
              here.(signal←⎕SIGNAL/∘{(⊃⍬⍴⎕DM)⎕EN})
              ss.retry_limit←10      ⍝ How many retries
              ss.retry_interval←0.25 ⍝ Length of first wait (increases with interval each wait)
              ss.orig←whoami''
              ss.homeport←7051
              ss.listen←localServer options.listen   ⍝ ⌽⊖'ISOL'
              ss.nextid←2⊃⎕AI                   ⍝ isolate id
              ss.callback←1+(2*15)|+/⎕AI        ⍝ queue for calls back
              z←⎕TPUT ss.assockey←1+ss.callback ⍝ queue for assoc and procs
              ss.assoc←dix'proc iso busy'(3⍴⍬ ⍬)
              ss.procs←0 5⍴0 ⍬'' 0 ''
     
              :If 1≡local ⍝ if we're to start local processes
                  ss.procs⍪←ss InitProcesses op
              :EndIf
     
              ss.started←sessionStart''               ⍝ last thing so we know
              r←1
          :Else
              signal''
          :EndTrap
      :EndIf
    ∇

    ∇ r←ss InitProcesses op;z;count;limit;ok;maxws;ws;rt;iso;ports;pids;pclts
      (count limit)←0 3
      maxws←' maxws=',⍕op.maxws
      (ws rt)←op.(workspace(runtime∧onerror≢'debug'))
      iso←('isolate=isolate onerror=',(⍕op.onerror),' isoid=',(⍕ss.callback),maxws)
      iso,←' protocol=',op.protocol
      ws←1⌽'""',checkWs addWSpath ws          ⍝ if no path ('\/')
      ports←ss.homeport+1+⍳op.(processors×processes)
      pids←(1⊃⎕AI)+⍳⍴ports
     
      :Repeat
          count+←1
          procs←{⎕NEW ##.APLProcess(ws ⍵ rt)}∘{'AutoShut=1 Port=',(⍕⍵),' APLCORENAME=',(⍕⍵),iso}¨ports
          procs.onExit←{'{}#.DRC.Close ''PROC',⍵,''''}¨⍕¨pids ⍝ signal soft shutdown to process
     
          pclts←pids InitConnections(ss.orig)ports(ss.callback)
     
          :If ~ok←~∨/0∊≢¨pclts ⍝ at least one failed
              ⎕←'ISOLATE: Unable to connect to started processes (attempt ',(⍕count),' of ',(⍕limit),')'
              ⎕DL 5 ⋄ {}procs.Kill ⋄ ⎕DL 5
              ports+←1+op.(processors×processes)
          :EndIf
      :Until ok∨count>limit
      'ISOLATE: Unable to initialise isolate processes'⎕SIGNAL ok↓11
      r←pids,procs,(⊂ss.orig),ports,⍪pclts
    ∇

    ∇ r←pids InitConnections(addr ports id);i
      r←(≢pids)⍴⊂''
      :For i :In ⍳≢pids
          :Trap 0
              (i⊃r)←(i⊃pids)InitConnection addr(i⊃ports)id
          :EndTrap
      :EndFor
    ∇

    ∇ r←pid InitConnection(addr port id);z;ok
      ok←0
      :If 0≠⊃z←DRCClt('PROC',⍕pid)addr port
          ('ISOLATE: Unable to connect to ',addr,':',(⍕port),':',,⍕z)⎕SIGNAL 11
      :Else ⍝ Connection made
          r←1⊃z
          :If 0=⊃z←DRC.Send r('#.isolate.ynys.execute'('' 'identify'))
          :AndIf 0=⊃z←DRC.Wait r 20000
              :If 0 'Receive'≡z[0 2]
                  :If ~ok←id∊¯1,3 1 1⊃z
                      r←'' ⍝ We got hold of someone elses server, don't use it
                  :EndIf
              :EndIf
          :Else
              {}DRC.Close r
              ('ISOLATE: New process did not respond to handshake:',,⍕z)⎕SIGNAL 11
          :EndIf
      :EndIf
      :If ~ok ⋄ {}DRC.Close r ⋄ :EndIf
    ∇

      InternalState←{⍺←⊢
          newSession'':⍳0 0
          {⍵.({⍵,⍪⍎⍕⍵}↓⎕NL 2)}⍣('namespace'≢minuscule ⍵)⊢session.assoc
⍝
      }

    ∇ r←{default}Values name
      :If 0=⎕NC'default' ⋄ default←⊢ ⋄ :EndIf
      r←⊃default(1⊃⎕RSI).(702⌶)name
    ∇

    ∇ r←Failed name
      r←(1⊃(1⊃⎕RSI).(702⌶)name)∊2 3
    ∇

    ∇ r←Running name;complete;failed
      r←0=1⊃(1⊃⎕RSI).(702⌶)name
    ∇

    ∇ r←Available name
      r←(1⊃(1⊃⎕RSI).(702⌶)name)∊4 5
    ∇

      New←{⍺←⊢
          z←Init 1
          trapErr''::signal''
          caller←callerSpace''
          source←caller argType ⍵
          id←⍬ isolates source
          proxy←caller.⎕NS proxyClone
          proxy.(iSpace iD iCarus)←iSpace id,suicide.New'cleanup'id
          z←proxy.⎕DF(⍕caller),'.[isolate]'
          z←1(700⌶)proxy
          1:proxy
⍝ simulate isolate primitive: UCS 164 / sol
      }

      StartServer←{⍺←⊢
          msg←messages'⍝- ' ⍝
          ~newSession'':(0⊃msg),' ',options.status
          z←Config'status' 'server'
          z←Init 1
     
          address←##.APLProcess.MyDNSName
     
          addresses←3↑⍤1↑1⊃DRC.GetProp'.' 'lookup'address 80
          addresses[;1]←¯3↓¨addresses[;1]
          addresses←addresses[⍋↑addresses[;2];0 1]
          addresses←addresses[;0]{⊂⍺ ⍵}⌸0 1↓addresses
     
          ports←∪session.procs[;3]
          info←(1 2⊃¨⊂msg),⍪address ports
          res←{4<≢⍵:msg[4 5 6 7],⍪address(⊃⍵)(≢⍵)''
              msg[4 5 7],⍪address((⊃⍵)+⍳≢⍵)''}ports
          res←∊⍕¨res
          ⎕←⍪,' ',⍪info(3⊃msg)res
          ⎕←⍪'' 'Full IP address list:' ''
          ⎕←addresses
          1:''
     
⍝- Session already started as
⍝- Machine Name:
⍝- IP Ports:
⍝- Enter the following in the client session:
⍝-       #.isolate.AddServer '
⍝- ' (
⍝- -⎕IO-⍳
⍝- )
      }

    ∇ x qsignal y
      ⍝ To help signal an error that will not terminate a dfn capsule
      y←(y 86)[y>999] ⍝ Use 86 for interrupts and CONGA ERRORS
      x ⎕SIGNAL y
    ∇

      addWSpath←{⍺←⊢
          ∨/'/\'∊ws←⍵:⊢ws       ⍝ assume extant path is good
          dir←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
          sep←⊃'/\'∩dir
          dir,←sep~⊢/dir        ⍝ append sep if needs
          dir,'ws',sep,ws       ⍝ WS folder
⍝ add ...dyalog/ws/   to ws if no path spec'd
      }

      and←{⍺←⊢
          ⍺⍺⊣⍵:⍵⍵⊣⍵
          0
⍝ left to right checking
⍝ try ⍵⍵ only if ⍺⍺ true
      }

      argType←{⍺←⊢
          trapErr''::signal''
          (0∊⍴)⍵:⍺.⎕NS''                                         ⍝ empty
          (0=≡)and{9=⎕NC'⍵'}⍵:⍵                                  ⍝ ns
          (1=≡)and(''≡0⍴⊢)⍵:checkWs ⍵
          (2=≡)and(''≡0⍴⊃)⍵:⍺.⎕NS↑⍵                              ⍝ nl
          ⎕SIGNAL 11
⍝ ⍺ caller
⍝ ⍵ arg to new - empty | space | namelist | string
⍝ ← :
⍝      arg | res
⍝      --- + ---
⍝    empty | empty ns
⍝    space | clone ns
⍝     list | ns containing named fns
⍝   string | validated wsid
      }

      callerSpace←{⍺←⊢
          ⍬⍴((0,⎕RSI)~0,⎕THIS,##,⍵),#
⍝ caller excluding this space and the main isolate method-space above it.
⍝ none of the code above is redundant. 2014-01-09
      }

      checkWs←{⍺←⊢
                                   ⍝ ⍵ IS a string
          z←⎕NS''
          0::'WS NOT FOUND'⎕SIGNAL ⎕DMX.EN  ⍝ any error bar Value
          6::⍵                          ⍝ value error implies copy ok
          z←{}'⎕IO'z.⎕CY ⍵              ⍝ force value error → return ⍵
⍝
      }

    ∇ r←cleanDM r;t;msg;line;caret;m
      →(0=⊃r)⍴0         ⍝ Not an error
      →(3≠⍴t←1⊃r)⍴0     ⍝ Not a ⎕DM
      (msg line caret)←t
      msg←('⍎'=⊃msg)↓msg
      :If 'f[] f←'≡6↑line ⋄ (line caret)←6↓¨line caret
      :ElseIf 'decode['≡7↑line
          :If ∨/':Case'⍷line ⋄ line←caret←''
          :ElseIf ∨/m←'c⌷[d]where.'⍷line
              (line caret)←(11+m⍳1)↓¨line caret
              line←((⌊/line⍳') ')↑line),'[...]',('←'∊line)/'←...'
          :Else ⋄ (line caret)←(1+line⍳']')↓¨line caret
          :EndIf
      :EndIf
      (1⊃r)←msg line caret
    ∇

      cleanup←{⍺←⊢
          trapErr''::signal''
          (chrid port numid)←⍵.(chrid port numid)
          ⎕←⍪'.'/⍨options.debug
          (ns←⎕NS proxyClone).(iD iSpace)←⍵ iSpace    ⍝ recreate temp proxy
          rem←{session.assoc.(iso proc busy⌿⍨←⊂iso≠⍵)}
          11::rem numid                               ⍝ DRC reported errors
          z←ns.iSend{⍵(1('{#.⎕EX''',⍵,'''}')0)}chrid  ⍝ expunge remote namespace
          z←DRC.Close chrid
          rem numid                                   ⍝ remove numid from table
          1:
⍝ called by destructor of suicide class when isolate proxy disappears.
⍝ ⍵     space: chrid port mumid
⍝ numid unique numeric identifier for isolate
⍝ chrid identifies DRC client and isolate space in remote process
⍝ port  on which process is listening
      }

    ∇ r←connect(chrid host port data);count
      :If 0=⊃r←DRCClt chrid host port  ⍝ DRCClt will retry
      :AndIf 0=⊃r←DRC.Send chrid data  ⍝ on any
      :AndIf 0=⊃r←DRC.Wait(1⊃r)20000 ⍝ error
      :Else
          {}DRC.Close chrid
          ('ISOLATE: Connection to ',host,':',(⍕port),' failed: ',,⍕r)qsignal 6
      :EndIf
⍝ connect and send Initial payload
⍝ ⍺     attempts
⍝ ⍵     client-id ip-port data
⍝ data  function and argument
⍝ ←     final return from DRC
    ∇

      dateNo←{⍺←⊢
          ⊢2 ⎕NQ'.' 'DateToIDN'⍵
      }

    ∇ res←where decode(a b c d e);home;x;DMX
      home←where=#  ⍝ would be #.IsoNNNNN for outward call
      x←where.⍎
      :Trap 999×{0::0 ⋄ ##.onerror≡⍵}'debug'
          :Select a
          :Case 0 ⋄ res←0(x b)
          :Case 1 ⋄ res←0((x b)c)
          :Case 2 ⋄ res←0(b(x c)d)
          :Case 3 ⍝ Assignment
              :If (0=⍴⍴c)∧1=≡c ⋄ where.⎕FX c ⋄ res←0 c ⍝ c is ⎕OR
              :Else ⋄ res←0(c⊢b{x ⍺,'←⍵'}c)
              :EndIf
          :Case 4 ⋄ res←0(⍎'c⌷[d]where.',b)
          :Case 5 ⋄ res←0(⍎'(c⌷[d]where.',b,')←e')
          :EndSelect
      :Else
          :If ⎕DMX.(EN ENX)≡11 4 ⍝ DOMAIN ERROR: isolate function iSyntax does not exist ...
              res←11((⊂'ISOLATE ERROR: Callbacks not enabled'),1↓⎕DM)
          :ElseIf ⎕DMX.((EN=6)∧∨/'##'⍷,⍕DM)
              res←6((⊂'VALUE ERROR IN CALLBACK'),1↓⎕DM)
          :Else
              res←⎕DMX.(EN DM)
          :EndIf
      :EndTrap
⍝ ⍺ target space
⍝ ⍵ encoded list
⍝   decode list and execute requisite syntax in target.
⍝   return (0 value) if OK, (⎕EN ⎕DM) on failure
⍝ Syntax cases:
⍝ a | b      | c       | d    | e
⍝ 0 | array  |         |      |
⍝ 0 | nilad  |         |      |
⍝ 0 | (expr) |         |      |
⍝ 1 | monad  | rarg    |      |
⍝ 2 | larg   | dyad    | rarg |
⍝ 3 | array  | value   |      |
⍝ 4 | array  | indices | axes |
⍝ 5 | array  | indices | axes | value
    ∇

      derv←{⍺←⊢
          ⍕{
              ⊃,/{
                  0=≡⍵:⍵
                  0∊⍴⍵:((''⍬ ⍵)⍳⊂⍵)⊃'''''' '⍬'⍵
⍝             1=≡⍵:'(',,∘')'⊃,/(⊂(' ',,⍵)⍳,⍵)⌷(⊂''' '' '),,⍵
                  1=≡⍵:'(',,∘')'⊃,/,⍵
                  ⊃,/'(',,∘')'∇¨⍵
              }⍵
          }⎕CR(f←⍺⍺)/'f'
⍝ ⍺⍺    derv
⍝ ←     executable text-string representation of ⍺⍺
⍝ sometimes adds too many parens but would need MUCH more analysis not to
⍝ handles scalar nums, ' ', '' & ⍬ but not arrays in general
⍝ e.g.
⍝       sec ← (⊢⊣)/∘⍳∘(15E5∘×)
⍝       sec derv 0
⍝ ((((⊢⊣)/)∘⍳)∘( 1500000 ∘×))
      }

      dix←{⍺←⊢
          r←(⍺⊣#).⎕NS''
          r⊣r.{⍎⍕'(',⍺,')←⍵'}/⍵
⍝ dictionary
⍝ [⍺]       container space for dictionary - dflt: #
⍝ ⍵         names values
⍝ names     ' '-del'd or nested list
⍝ values    conformable with names
⍝ e.g.      pt←(dix'⎕ml'3).⊂
      }

      easy←{⍺←⊢
          expose ⎕THIS(↓##.⎕NL 3 4)
⍝ expose public functions in root
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

    ∇ r←execute(name data);z;n;space;zz
      :If name≡''
          :Select data
          :Case 'identify' ⍝ return isoid
              r←0(⊃1⊃⎕VFI+2 ⎕NQ'.' 'GetEnvironment' 'isoid')
          :Else
              r←11('ISOLATE: Unknown command'data)
          :EndSelect
      :Else
          space←#.⍎name
          :Hold 'ISO_',name
              :If {0::0 ⋄ ##.onerror≡⍵}'debug' ⋄ ⎕TRAP←0 'S' ⋄ :EndIf
              r←space decode 5↑data
     
              :If 0=⎕NC'session' ⍝ In the isolate
                  :Trap 6
                      z←+r ⍝ Block on futures here to provoke (and trap) the VALUE ERROR
                  :Else
                      :If 2=⎕NC n←name,'error'
                          r←⍎n ⋄ ⎕EX n
                          (1 0⊃r),←' IN CALLBACK'
                      :Else
                          r←6('VALUE ERROR: Callback failed'(1⊃data)'^')
                      :EndIf
                  :EndTrap
                  :If (⎕NC⊂'zz'⊣zz←1⊃r)∊9.2 9.4 9.5
                      r←11('ISOLATE ERROR: Result cannot be returned from isolate' '')
                  :EndIf
     
              :EndIf
              r←cleanDM r
          :EndHold
      :EndIf
⍝ this is the function called by RPCServer.Process
⍝ ⍵     name data
⍝ data  list created by encode below.
⍝ ←     result or assignment of decoded ⍵
    ∇

      expose←{⍺←⊢
          (src snm)←⍵
          (tgt tnm)←⍺⊣#             ⍝ dflt target  - #
          tnm←snm∘⊣⍣(tgt≡tnm)⊢tnm   ⍝ dflt tnames  - snames
          ss←⍕src
          trap←'⋄0::(⊃⍬⍴⎕DMX.EN) ⎕SIGNAL ⎕DMX.⎕EN⋄'
          fix←{op←4=src.⎕NC ⍵
              (aa ww)←2↑(0 2⊃src.⎕AT ⍵)⍴'⍺⍺' '⍵⍵'
⍝         tgt.⎕FX(⍺,'←{⍺←⊢')trap('⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵')('⍺(',aa,ss,'.',⍵,ww,')⍵')'}'
              tgt.⎕FX,⊂⍺,'←{⍺←⊢',trap,(op/'⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵⋄'),'⍺(',aa,ss,'.',⍵,ww,')⍵}'
          }
          z←tnm fix¨snm
          1:1
⍝ expose public functions and operators elsewhere
⍝ ⍵         (src) (snms)
⍝ ⍺         [tgt  [tnms] ]
⍝ src       ref containing fns to run
⍝ snms      names of fns & ops therein
⍝ tgt       ref to contain fns to call - dflt #
⍝ tnms      corresponding names in tgt - dflt snms
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄                      ⍺(  #.src.snm  )⍵} ⍝ function
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄ ⍵≡⍺⍵:⍺⍺#.src.snm  ⊢⍵⋄⍺(⍺⍺#.src.snm  )⍵} ⍝ adverb
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄ ⍵≡⍺⍵:⍺⍺#.src.snm⍵⍵⊢⍵⋄⍺(⍺⍺#.src.snm⍵⍵)⍵} ⍝ conjunction
      }

      fnSpace←{⍺←⊢
     
          trapErr''::signal''
          s←(callerSpace'').⎕NS''
          N←,⍵
          f←⍺⍺
          c←⎕CR'f'
          q←'#'≡⊃⊃c    ⍝ qualified
          c←⊃∘⌽⍣q⊢c    ⍝ remove qualification
          d←'{'≡⍬⍴c    ⍝ anon dfn
          t←1=≢⍴c      ⍝ tacit derv
          n←s.⎕FX{,↓⍣(1=≡⍵){N,'←',1↓,'⋄',⍵}⍣d⊢⍵}c
     ⍝ name anon dfn as N
          z←s.⎕FX(,↓N,'←{⍺←⊢ ⋄ ⍺',n,'⍵}')/⍨~(⊂n)∊N 0 1
     ⍝ if not N then N calls it
          z←s.⍎⍣t⊢N,'←',f derv⍣t⊢0
          1:s
⍝ ⍺⍺ fn
⍝ ⍵  required name for fn in space
⍝ ←  space child of caller containing fn as ⍵
⍝    for use by ephemeral isolates in llEach &c.
     
          trapErr''::signal''
          op←{}
          z←⎕FX,⊂'op←{⍵.',⍵,'←⍺⍺ ⋄ ⍵}'
          1:⍺⍺ op(callerSpace'').⎕NS''
⍝ possible alternative algorithm 2014-03-09
⍝ so far I can't find the reason I thought I needed
⍝ all the other stuff as this seems to do it ok.
     
      }

      getDefaultWS←{
          ∨/⍵⍷⎕WSID:⎕WSID
          ⍵ ⍝ ⍵ is normally 'isolate'
⍝ use exact current ws if looks like an isolate development ws
      }

      getDRC←{⍺←⊢
          ⍵≠#:⍵                          ⍝ if not # it must exist
          9=#.⎕NC'DRC':#.DRC             ⍝ in # already?
          ws←addWSpath'conga'            ⍝ dyalog WS
          0::⊢#.DRC                      ⍝ this is result
          z←{}'DRC'#.⎕CY ws              ⍝ ⎕CY no result
⍝
      }

      getSet←{⍺←⊢
     
          0∊⍴⍵:{(~⍵[;0]∊'debug' 'status')⌿⍵}options.({⍵,⍪⍎⍕⍵}⎕NL-2 9)
          one←1=≡⍵
          two←one<(,2)≡⍴⍵
          sig11←⎕SIGNAL∘11
          msg←'Argument should be '''', name or (name value)'
          one⍱two:sig11 msg
          (nam new)←⊂⍣one⊢⍵
          ''≢0⍴nam:sig11 msg
          nam←minuscule nam
          ~(⊂nam)∊options.⎕NL-2 9:sig11'Unknown parameter: ',nam
          old←options.⍎nam
          one:old
     
⍝ then two
          and←{⍺⍺⊣⍵:⍵⍵⊣⍵ ⋄ 0}
          (range type)←(domains types).⍎⊂nam
          s b i r←'SBIR'=type
          msg←nam,' should be a',⍕s b i r/'string' 'boolean' 'integer' 'ref'
          ok←b and(⊢≡1=⊢)new
          ok←ok∨i and{0=1↑0⍴⍵}and(⊢=⌊)new
          ok←ok∨s and{''≡0⍴⍵}new
          ok←ok∨r and{9=⎕NC'⍵'}new
          ~ok:sig11 msg
          ok←ok∧((1=⍴)∨(⊂new)∊⊢)range
          ~ok:sig11⍕nam,' should be one of:',range
     
          (ws db li)←'workspace' 'debug' 'listen'∊⊂nam ⍝ special
          0::(⊃⎕DMX.DM)⎕SIGNAL ⎕DMX.EN                         ⍝
          z←checkWs⍣ws⊢new                             ⍝
          z←{⎕THIS.(trapErr←(⍵↓0)∘⊣) ⋄ 0}⍣db⊢new       ⍝
          z←localServer⍣li⊢new                         ⍝ cases
          old⊣nam options.{⍎⍺,'←⍵'}new
     
⍝    }⍵
⍝ ⍺ target space
⍝ ⍵ '' | name | name value
⍝ ← (⍵:'') all names and values
⍝   (⍵:name) value
⍝   (⍵:name value) value re-assigned
⍝ called by both Config and setDefaults
      }

      isoStart←{⍺←⊢
     
          ##.onerror←2 ⎕NQ'.' 'GetEnvironment' 'onerror'
          protocol←2 ⎕NQ'.' 'GetEnvironment' 'protocol'
          iso←'isolate'
          parm←2 ⎕NQ'.' 'GetEnvironment'iso
          parm≢iso:shy←1
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

      isolates←{⍺←⊢
          ss←session
          source←⍵                    ⍝ ns or wsid
          receive←(⍕⎕THIS),'.receive'
          numid←ss.nextid←ss.nextid+2
          tgt←'#.',chrid←'Iso',⍕numid
     
⍝ ss.procs contains all proc ids; assoc.(busy/proc) only those with busy isos
          max←options.isolates
          ass←ss.assoc
          z←⎕TGET ss.assockey         ⍝ see Init
          procs←⊣/ss.procs
          load←¯1+{≢⍵}⌸procs,ass.proc         ⍝ isolate load
          busy←¯1+{≢⍵}⌸procs,ass.(busy/proc)  ⍝ busy isolates
          ok←options.isolates>load
          ~∨/ok:'ISOLATE ERROR: All processes are in use'⎕SIGNAL 11⊣⎕TPUT ss.assockey
          use←(load=⌊/load)/⍳⍴load ⍝ procs with same load
          proc←procs⊃⍨use←use[⊃⍋busy[use]]     ⍝ pick one with fewest busy isolates
          ass.(iso busy proc),←numid 0,proc
          z←⎕TPUT ss.assockey
          (host port)←ss.procs[procs⍳proc;2 3]
          data←host ss.orig chrid numid tgt ss.homeport port
          id←dix'host orig chrid numid tgt home port'data
          z←connect chrid host port,⊂receive(source options.listen id)
          id
⍝ Create DRC client for isolate.
⍝ Create id space to send and return for corresponding proxy.
      }

      ll←{⍺←⊢
          z←Init 1
          trapErr''::signal''
          s←⍺⍺ fnSpace'f'
     
          i←New s
          ⍵≡⍺ ⍵:i.f ⍵    ⍝ monad
          ⍺ i.f ⍵        ⍝ dyad
     
⍝ parallel
⍝ ⍺     [larg]
⍝ ⍺⍺    [fn to apply to or between [⍺] and or ⍵
⍝ ⍵     rarg
⍝ ←     result of running ⍺⍺ in a parallel process.
      }

      llEach←{⍺←⊢
          z←Init 1
          trapErr''::signal''
          n←⍺⍺ fnSpace'f'
          s←⍴⍺⊢¨⍵
          i←New¨s⍴n
          ⍵≡⍺ ⍵:i.f ⍵    ⍝ monad
          ⍺ i.f ⍵        ⍝ dyad
     
⍝ parallel each
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding items of [⍺] and/or ⍵
⍝ ⍵     rarg
⍝ ←     results (which may be futures) of running ⍺⍺ in each
⍝       of one or more ephemeral isolates
      }

      llKey←{⍺←⊢                                    ⍝ key operator
          z←Init 1
          trapErr''::signal''
          ⍵≡⍺ ⍵:⍵ ∇(callerSpace'').⍳≢⍵
     
          j←⍋i←{(∪⍳⊢)↓⍣(≢1↓⍴⍵)⊢⍵}⍺
          (⊂⍤¯1⊢((⍳⍴i)=i⍳i)⌿⍺)⍺⍺ llEach(2≠/¯1,i[j])⊂[0](⊂j)⌷⍵
     
⍝ parallel key : ⍺ ⍺⍺ llkey ⍵
⍝ ⍺     [larg] - array (≢⍺) ≡ ≢⍵
⍝       ⍺⍺ llKey ⍵ ←→ ⍵ ⍺⍺ llKey ⍳≢⍵
⍝ ⍺⍺    fn to apply between each unique major cell of ⍺ and
⍝       the corresponding subarray of ⍵ ; or to the latter.
⍝ ⍵     rarg - array
⍝ ←     futures array - results of each application of ⍺⍺
⍝ to emulate primitive key completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it would dereference the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
      }

      llOuter←{⍺←'VALENCE ERROR'⎕SIGNAL 6
          z←Init 1
          trapErr''::signal''
          (⍉(⌽s)⍴⍉⍺)⍺⍺ llEach ⍵⍴⍨s←(⍴⍺),⍴⍵
     
⍝     s←,⍴a←∪,⍺
⍝     s,←⍴w←∪,⍵
⍝     r←(⍉(⌽s)⍴⍉a)⍺⍺ llEach s⍴w
⍝     1:r[a⍳⍺;w⍳⍵]
     
⍝ parallel outer product
⍝ ⍺  array
⍝ ⍺⍺ fn to apply between items of ⍺ and ⍵
⍝ ⍵  array
⍝ ←  aray of futures from ⍺⍺ applied between
⍝    each pair of items selected from ⍺ and ⍵
      }

      llRank←{⍺←⊢
          z←Init 1
          trapErr''::signal''
          mlr←⌽3⍴⌽⍵⍵,⍬
          m←⍵≡⍺ ⍵
          l r←-1↓r⌊|l+r×0>l←(⊂⍒m×⍳3)⌷mlr⌊r←3⍴(⍴⍴⍵),⍴⍴⍺⊣0
          w←⊂[r↑⍳⍴⍴⍵]⍵
          m:⍺⍺ llEach w              ⍝ monad
          (⊂[l↑⍳⍴⍴⍺]⍺)⍺⍺ llEach w    ⍝ dyad
⍝ parallel rank
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding cells of [⍺] and/or ⍵
⍝ ⍵⍵    ranks (monadic, left, right) of cells of [⍺] and/or ⍵
⍝           to or between which to apply ⍺⍺
⍝ ⍵     rarg
⍝ ←     results or futures from running ⍺⍺ in each of one
⍝           or more ephemeral isolates
⍝ to emulate primitive rank completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it dereferences the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
      }

    ∇ r←localServer r;srv;rc;z
      →(0=⎕NC'session.homeport')⍴0
     
      :If r=0
      :AndIf r←DRC.Exists srv←'ISO',⍕session.homeport ⍝ Server exists
          {}DRC.Close srv ⍝ Left over - object there but no thread
          :If 2=⎕NC'session.listeningtid'
              ⎕TKILL session.listeningtid
              ⎕EX'session.listeningtid'
          :EndIf
      :Else
     
          :If r←DRC.Exists srv←'ISO',⍕session.homeport ⍝ Server exists
              :If r←2=⎕NC'session.listeningtid'
              :AndIf r←session.listeningtid∊⎕TNUMS
              :Else
                  {}DRC.Close srv ⍝ Left over - object there but no thread
              :EndIf
          :EndIf
     
          :If ~r ⍝ Already got a listening server
          :AndIf options.listen
              :Repeat
                  :If r←0=rc←⊃z←1 1 ##.RPCServer.Run srv session.homeport
                      session.listeningtid←1⊃z
                  :ElseIf 10048=rc ⍝ Socket already in use
                      session.homeport+←options.(1+processes×processors)
                  :EndIf
              :Until r∨session.homeport>options.homeportmax
              ('Unable to create listener: ',,⍕z)⎕SIGNAL r↓11
          :EndIf
      :EndIf
    ∇

      messages←{⍺←⊢
          {(+/∨\' '≠⌽⍵)↑¨↓⍵}⍵{(0,⍴,⍺)↓⍵⌿⍨>/⍺⍷⍵}⎕CR⊃1↓⎕XSI
⍝ attached to caller
      }

      minuscule←{⍺←⊢
          ('abcdefghijklmnopqrstuvwxyz',,⍵)[(⎕A,,⍵)⍳⍵]
⍝
      }

    ∇ r←newSession w;z
      :If 0=⎕NC'session.started'
      :OrIf 0.0001<|session.started-sessionStart''
          r←1
      :Else ⋄ r←0 ⍝ not a new session
          session.listen←options.listen
          checkLocalServer ⍬
      :EndIf
     
⍝ The session is new if session.started is missing.
⍝ It needs to be restarted if session.started differs from the actual
⍝ start of the session by more than 8.64 seconds (1/10000 of a day)
⍝ that indicates that the ws was saved with the session space intact
    ∇

    processors←{1111⌶⍬}

      prof←{⍺←⊢ ⋄ ⎕IO←0
          z←⎕PROFILE'clear'
          z←⎕PROFILE'start'
          r←⍺ ⍺⍺⍣⍵⍵⊢⍵
          z←⎕PROFILE'stop' ⋄ e←⍬⍴⎕LC
          p←e↓⎕PROFILE'data'
          p[;3 4]{⌊0.5+100×⍺÷⍵}←0 4⌷p
          p[;]←p[⍒p[;3];]
          n←{⍺,~∘' '⍕,'[',(⍪⍵),']'}/2↑⍤1⊢p
          p←4↑⍤1⊢n,0 2↓p
          p⍪⍨←'operation[]' 'called' 'exclusive %' 'inclusive %'
          r p
⍝ ⍺     [larg]
⍝ ⍺⍺    fn
⍝ ⍵⍵    rop to ⍣ (fn or int)
⍝ ⍵     rarg
⍝ ←     res prof
⍝ res   result of: ⍺ ⍺⍺⍣⍵⍵⊢⍵
⍝ prof  ⎕profile wherein
⍝       cols[0,1] joined as fnname[lineno]
⍝       times converted to % so ⍺⍺ takes 100 overall
⍝       last two cols missing
      }

      publicMethods←{⍺←⊢
          messages'⍝- '
⍝- AddServer
⍝- Config
⍝- InternalState
⍝- LastError
⍝- New
⍝- StartServer
⍝- RemoveServer
⍝- Stats
⍝- ll
⍝- llEach
⍝- llKey
⍝- llOuter
⍝- llRank
     
⍝ add more after prefix '⍝- '
      }

      receive←{⍺←⊢
          (source listen id)←⍵                           ⍝ this all happens remotely
          name←id.chrid
          root←⎕NS''
          z←{root.⎕FX¨proxySpace.(⎕CR¨⎕NL ¯3),⊂⎕CR'tracelog'}⍣listen⊢1  ⍝ prepare for calls back
          root.iSpace←⎕THIS
          id.(port←home)
          id.(chrid←'Iso',⍕1+numid)
          id.tgt←,'#'
          root.iD←id
          iso←root.⎕NS(⍴⍴source)⊃source''                ⍝ clone of source
          z←iso.{6::0 ⋄ z←{}⎕CY ⍵}⍣(≡source)⊢source      ⍝ or copy if ws
          z←iso.{6::0 ⋄ z←{}(↑'⎕io' '⎕ml')⎕CY ⍵}⍣(≡source)⊢source
          z←name{#.⍎⍺,'←⍵'}iso                           ⍝ name it in root
          z←#.DRC.Clt⍣listen⊢id.(chrid orig port)        ⍝ orig=host if local
          1⊣1(700⌶)root                                  ⍝ Make isolate
      }

    ∇ r←RemoveServer server;mask;iso;isos;clt;mask2;local;ok;count
      :If 2=⎕NC'session.procs'
          :If 0=⍴server ⋄ server←whoami'' ⋄ :EndIf
          :If ∨/mask←server∘≡¨session.procs[;2]
              :If 2=⎕NC'session.assoc.proc'
                  :If 0≠≢isos←(mask2←session.assoc.proc∊mask/session.procs[;0])/session.assoc.iso
                      :For iso :In isos
                          {}DRC.Close'Iso',⍕iso
                      :EndFor
                      session.assoc.(busy iso proc)/⍨←⊂~mask2
                  :EndIf
              :EndIf
     
              :For clt :In mask/session.procs[;4]
                  {}DRC.Close clt
              :EndFor
     
              :If 0≠≢local←{(⍵≠0)/⍵}mask/session.procs[;1]
                  :If 'server'≡options.status
                      local.Kill
                  :Else
                      count←0
                      :While ~ok←∧/local.HasExited
                          ⎕DL session.retry_interval×count←count+1
                      :Until count>session.retry_limit
                  :EndIf
              :EndIf
              session.procs⌿⍨←~mask
              r←State''
          :Else
              r←'[server "',server,'" not found]'
          :EndIf
      :Else
          r←'[no servers defined]'
      :EndIf
    ∇

    ∇ r←Reset kill;iso;clt;ok;local;count
      r←''
      :If 2=⎕NC'session.assoc.iso'
          r,←(⍕≢session.assoc.iso),' isolates, '
          :For iso :In session.assoc.iso ⍝ For each known isolate
              {}DRC.Close'Iso',⍕iso
          :EndFor
      :EndIf
     
      :If 2=⎕NC'session.procs'
          r,←(⍕≢session.procs),' processes, '
          :For clt :In session.procs[;4] ⍝ For each process
              {}DRC.Close clt
          :EndFor
     
          count←0
          :If 0≠≢local←session.((procs[;1]≠0)/procs[;1]) ⍝ local processes
     
              :If 'server'≡options.status
                  r←r,' (service processes killed), ' ⋄ local.Kill
              :Else
                  :While ~ok←∧/local.HasExited
                      ⎕DL session.retry_interval×count←count+1
                  :Until count>session.retry_limit
                  r←r,(~ok)/' (service processes have not died), '
              :EndIf
     
          :EndIf
      :EndIf
     
      :If 2=⎕NC'session.listeningtid'
          ⎕TKILL session.listeningtid
          r,←'callback listener, '
      :EndIf
     
      :If 0≠≢r ⋄ r←'Reset: ',¯2↓r
      :Else ⋄ r←'Nothing found to reset'
      :EndIf
      ⎕EX'session'
    ∇

      sessionStart←{⍺←⊢
          24 60 60 1000{(dateNo ⍵)-(⍺-⍺⍺⊥3↓⍵)÷×/⍺⍺}/(2⊃⎕AI)⎕TS
⍝ diff twixt ⎕ts and ⎕ai
⍝ ← number of days and the decimal part thereof after the start of the last
⍝   day of the penultimate year of the nineteenth century: 1899-12-31 00.00
⍝ immune to system clock change as both rely on that.
      }

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
              spaces.runtime←tod'B' 1                   ⍝ use runtime version
              spaces.protocol←tod'S' 'IPv4' 'IPv6' 'IP' ⍝ default to IPv4
              spaces.maxws←tod'S'(2 ⎕NQ'.' 'GetEnvironment' 'maxws')
              spaces.status←tod'S' 'client' 'server'    ⍝ set as 'server' by StartServer
              spaces.workspace←tod'S'(getDefaultWS'isolate') ⍝ load current ws for remotes?
              1:1
          }⍣new⊢0
          0::(⊃⍬⍴⎕DMX.DM)⎕SIGNAL ⎕DMX.EN
          ⊢getSet ⍵                                     ⍝ this where Config called prior Init
     ⍝ called by Config before Init runs and by Init when it does.
⍝ set default options and permit user changes
⍝ but leave Init to apply them.
      }

    ∇ r←State dummy;counts
     ⍝ Return current process & isolate state
     
      :If 9=⎕NC'session'
          :If 0≠≢session.procs
              counts←session.assoc.(proc{⍺,(+/⍵),+/~⍵}⌸busy)
              r←session.procs[;2 3]
              r,←{⍵,+/⍵}(counts⍪0)[counts[;0]⍳session.procs[;0];1 2]
              r[(0,2≡/r[;0])/⍳1↑⍴r;0]←⊂''
              r←({⍵,[¯0.5](≢¨⍵)⍴¨'-'}'Host' 'Port' 'Busy' 'Idle' 'Isolates')⍪r
              r←r[;0 1 4 2]
          :Else
              r←'[no servers defined]'
          :EndIf
      :Else
          r←'[not initialised]'
      :EndIf
    ∇

    ∇ r←Stats dummy;n;stats;proc;z
      :If 9=⎕NC'session'
          :If 0≠n←≢session.procs
              stats←⍬
              :For proc :In session.procs[;4]
                  :If 0=⊃z←DRC.Send proc('ß' '')
                  :AndIf 0=⊃z←DRC.Wait 1⊃z
                  :AndIf 0=⊃z←3⊃z
                      stats,←z[1]
                  :Else
                      stats,←⊂⍬
                  :EndIf
              :EndFor
              r←session.procs[;2 3]
              r[(0,2≡/r[;0])/⍳1↑⍴r;0]←⊂''
              r,←↑stats
              r[;2]←↓'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 0 ¯1↓↑r[;2]
              r←({⍵,[¯0.5](≢¨⍵)⍴¨'-'}'Host' 'Port' 'Start' 'Cmds' 'Errs' 'CPU')⍪r
          :Else
              r←'[no servers defined]'
          :EndIf
      :Else
          r←'[not initialised]'
      :EndIf
    ∇

    ∇ stop;⎕TRAP
      ⎕TRAP←0 'S' ⋄ ∘
    ∇

      until←{⍺←⊢ ⋄ f←⍺⍺ ⋄ t←⍵⍵
          ⍵≡⍺ ⍵:f⍣(t⊣)⍵
          ⍺{ ⍝ keep recursion local
              (⍺-1)∘∇⍣((⍺>1)>t z)⊢z←f ⍵
          }⍵
⍝ ⍺     [max]
⍝ ⍺⍺    monadic fn on arg - may be composed: (const∘function)
⍝ ⍵⍵    monadic test on arg or subsequent results
⍝ ⍵     arg
⍝       apply fn [up to max times] until test result
⍝ ←     last application of fn
⍝ e.g.
⍝       10 +∘1 until (≥∘5) 0
⍝ 5
⍝       10 +∘1 until (≥∘15) 0
⍝ 10
⍝       +∘1 until (≥∘5) 0
⍝ 5
⍝       +∘1 until (≥∘15) 0
⍝ 15
      }

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

      ynys←{⍺←⊢
⍝ ynys - Welsh - island - cognate with insular, isolate &c.
⍝ and beginning with "y" it's at the bottom of autocomplete
      }


    :namespace proxySpace
   ⍝ ## ←→ #.isolate.ynys

        (⎕IO ⎕ML)←0 1

          iEvaluate←{⍺←⊢
              data←⍺ iSpace.encode ⍵
              ID←iD.numid
              ss←{iSpace.session}⍣home⊢home←2∊⎕NC'iSpace.session.started' ⍝ is this true ?
              z←{iso←ss.assoc.iso
                  (≢iso)≤i←iso⍳⍵:'ISOLATE: No longer accessible'⎕SIGNAL 6
                  (i⊃ss.assoc.busy)←1}⍣home⊢ID
              (rc res)←z←iSend iD.tgt data      ⍝ the biz
              ok←0=rc
              ~home:{rc=0:⍵ ⋄ ⍎'#.Iso',(⍕ID),'error←rc ⍵' ⋄ ⎕SIGNAL rc}res   ⍝ call back? then we're done
              z←ss.assoc.{((iso⍳⍵)⊃busy)←0}ID
              ok:⊢res                           ⍝ spiffing!
              (,⍕(⍕rc),': ',(0⊃res),{(⍵∨.≠' ')/': ',⍵}1⊃res)iSpace.qsignal rc
   ⍝ execute expression supplied to isolate
          }

        ∇ r←iSend data;send;ev;nm;rc;res;cmd
          send←((⍕iSpace),'.execute')data    ⍝ RPCServer runs this
          :Trap 0 ⋄ res←iSpace.DRC.Send iD.chrid send
          :Else
              ⍝ ⎕←'ISOLATE: Transmission failure: ',⎕DMX.Message
              'ISOLATE: Transmission failure'iSpace.qsignal 6
          :EndTrap
          rc cmd ev data←4↑res
          :If 0≠rc ⋄ r←86(('COMMUNICATIONS FAILURE ',⍕rc cmd)ev)          ⍝ ret ⎕EN ⎕DM
          :Else
         WAIT:
              :Trap 1000
                  :Repeat
                      res←(rc nm ev data)←4↑iSpace.DRC.Wait cmd
                  :Until ~(rc=100)∨ev≡'Progress'
              :Else
                  iSpace.checkLocalServer ⍬
                  ⍞←'ISOLATE: Interrupt - continue waiting (Y/N)? '
                  →(∨/'Yy'∊⊃{(1+⍵⍳'?')↓⍵}⍞~' ')⍴WAIT
                  ('USER INTERRUPT ',⍕⎕DMX.EN)iSpace.qsignal 6
              :EndTrap
              :If rc=0
                  :If 0=⊃data ⋄ r←1⊃data     ⍝ if rc is 0 res which will be (0 result)
                  :Else ⋄ r←(1↑data),⊂1↓data,⊂'' ⍝ error from RPCServer framework itself
                  :EndIf
              :Else ⋄ r←rc((⍕rc nm)ev) ⍝ else return rc and faked ⎕DM
              :EndIf
   ⍝ called from iSyntax, iEvaluate and from
   ⍝ ##.cleanup to remove isolate from remote process
          :EndIf
        ∇

          iSyntax←{⍺←⊢
              ⍝z←tracelog ⍵
              c←⊣/⍵
              '('=c:⊢3 32                            ⍝ if '(expr)' ⍝ 1 0 0 0 0 0
              '{'=c:⊢3 52                            ⍝ if '{defn}' ⍝ 1 1 0 1 0 0
              '#'∊⍵:⊢0 0                             ⍝ # in anything un-parenthesised is an error
              '⎕'=c:⊢{0::0 0 ⋄ x←⍎⍵ ⋄ c←⎕NC'x' ⋄ (2 3⍳c)⊃(2 0)(3 52)(0 0)}⍵ ⍝ assumes ⎕FNS ambi
                                               ⍝ ↑ reject ops & nss
              f←',⊢-⊂⍴⊃≡+!=⍳⊣↓↑|⍪⍕⍎∊⌽~×≠>⌊∨?⌷<≢⌈≥⍷⍉∪÷⍒⊥∧⍋⊖*○⍲⍱⍟⌹⊤≤∩'
         
              c∊f:⊢3 52
              0>⎕NC ⍵:⊢0 0                           ⍝ primitive operators
              expr←'((2⍴⎕nc∘⊂,⎕at),''',⍵,''')'       ⍝ then what is it?
              (rc res)←iSend iD.tgt(0 expr)          ⍝ from the horse's mouth
              (nc at)←res                            ⍝ ⎕NC ⎕AT - rc?
              nc∊3.2 3.3:⊢3 52                       ⍝ 3,32+16+4 res ambi omega
              c←⌊nc                                  ⍝ class
              c∊0 2:⊢2 0                             ⍝ undef, var
              (r fv ov)←at                           ⍝ result, valence
              w←∨/(a d w)←fv=¯2 2 1                  ⍝ (ambi, dyad, omega)
              r←c,2⊥r a d w 0 0                      ⍝ class, encoded syntax
              1:⊢r
   ⍝ return nameclass and syntax for supplied name (string)
          }

    :endnamespace ⍝ proxySpace

    :Class suicide
        ∇ inst←New data;whence
          :Access public shared
          whence←⍬⍴⎕RSI
          inst←whence.⎕NEW ⎕THIS
          inst.(whence data)←whence data
        ∇

        ∇ coroner
          :Implements destructor
          :Trap 0
              (fn arg)←data
              (whence.⍎fn)arg
          :EndTrap
        ∇
   ⍝ set a destructor on an ordinary container space.
   ⍝ When the space into which the instance is set,
   ⍝ e.g. 'this' in:
   ⍝       this.close←suicide.New name arg
   ⍝ is destroyed, the function named as the first of
   ⍝ two items in New's argument, that must be in the
   ⍝ space that called 'New', is called with the second
   ⍝ item of that same arg and can be made to release
   ⍝ resources even though space - 'this' has gone.
   ⍝ Phil Last ⍝ 2013-06-29 10:31
    :EndClass
:endnamespace ⍝ ynys
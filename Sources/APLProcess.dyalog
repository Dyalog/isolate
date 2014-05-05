:Class APLProcess
    ⍝ Start (and eventually dispose of) a Process
    ⍝ Based on Parallel workspace

    (⎕IO ⎕ML)←1 1

    :Field Public Args←''
    :field Public Ws←''
    :field Public Exe←''
    :Field Public Proc←⎕NS ''
    :Field Public onExit←''

    endswith←{w←,⍵ ⋄ a←,⍺ ⋄ w≡(-(⍴a)⌊⍴w)↑a}
    tonum←{⊃⊃(//)⎕VFI ⍵}
    eis←{2>|≡⍵:,⊂⍵ ⋄ ⍵} ⍝ enclose if simple

    ∇ make args;rt;cmd;ws
      :Access Public Instance
      :Implements Constructor
      ⍝ args is:
      ⍝  [1]  the workspace to load
      ⍝  [2]  any command line arguments
      ⍝ {[3]} if present, a Boolean indicating whether to use the runtime version, OR a character vector of the executable name to run
      args←{2>|≡⍵:,⊂⍵ ⋄ ⍵}args
      args←3↑args,(⍴args)↓'' '' 0
      (ws cmd rt)←args
      Start(ws cmd rt)
    ∇

    ∇ Start(ws args rt);psi;pid
      (Ws Args)←ws args
      :If ~0 2∊⍨10|⎕DR rt ⍝ if rt is character, it's the executable name
          Exe←(RunTime⍣rt)GetCurrentExecutable
      :Else
          Exe←rt
          rt←0
      :EndIf
   ⍝   ws,←rt/' salt'  ⍝ if runtime, load the salt workspace first, which will subsequently load the target workspace
      :If IsWin
          ⎕USING←'System,System.dll'
          psi←⎕NEW Diagnostics.ProcessStartInfo,⊂Exe(ws,' ',args)
          psi.WindowStyle←Diagnostics.ProcessWindowStyle.Minimized
          Proc←Diagnostics.Process.Start psi
      :Else ⍝ Unix
          pid←_SH'{ ',args,' ',Exe,' +s ',ws,' -c APLppid=',(⍕GetCurrentProcessId),' </dev/null >/dev/null 2>&1 & } ; echo $!'
          Proc.Id←pid
          Proc.HasExited←HasExited
          Proc.StartTime←⎕NEW Time ⎕TS
      :EndIf
    ∇

    ∇ Close;count;limit
      :Implements Destructor
      WaitForKill&200 0.1 ⍝ Start a new thread to do the dirty work
    ∇

    ∇ WaitForKill(limit interval);count
      :If (0≠⍴onExit)∧~HasExited ⍝ If the process is still alive
          :Trap 0 ⋄ ⍎onExit :EndTrap ⍝ Try this
     
          count←0
          :While ~HasExited
              {}⎕DL interval
              count←count+1
          :Until count>limit
      :EndIf ⍝ OK, have it your own way
     
      {}Kill Proc
    ∇

    ∇ r←IsWin
      r←'Win'≡3↑⎕IO⊃#.⎕WG'APLVersion'
    ∇

    ∇ r←GetCurrentProcessId;t
      :Access Public
      :If IsWin
          r←⍎'t'⎕NA'U4 kernel32|GetCurrentProcessId'
      :Else
          r←tonum⊃_SH'echo $PPID'
      :EndIf
    ∇

    ∇ r←GetCurrentExecutable;⎕USING;t
      :Access Public Shared
      ⎕USING←'System,system.dll'
      :If IsWin
          r←2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
          r←r,(~(¯1↑r)∊'\/')/'/' ⍝ Add separator if necessary
          r←r,(Diagnostics.Process.GetCurrentProcess.ProcessName),'.exe'
      :Else
          t←⊃_SH'ps -p ',(⍕GetCurrentProcessId),' h -o cmd'
          :If '"'''∊⍨⊃t  ⍝ if command begins with ' or "
              r←{⍵/⍨{∧\⍵∨≠\⍵}⍵=⊃⍵}t
          :Else
              r←{⍵↑⍨¯1+1⍳⍨(¯1↓0,⍵='\')<⍵=' '}t ⍝ otherwise find first non-escaped space (this will fail on files that end with '\\')
          :EndIf
      :EndIf
    ∇

    ∇ r←RunTime exe
    ⍝ Assumes that:
    ⍝ Windows runtime ends in "rt.exe"
    ⍝ *NIX runtime ends in ".rt"
      r←exe
      :If IsWin
          :If 'rt.exe'≢{('rt.ex',⍵)[⍵⍳⍨'RT.EX',⍵]}exe ⍝ deal with case insensitivity
              r←'rt.exe',⍨{(~∨\⌽<\⌽'.'=⍵)/⍵}exe
          :EndIf
      :Else
          r←exe,('.rt'≢¯3↑exe)/'.rt'
      :EndIf
    ∇


    ∇ r←KillChildren Exe;kids;⎕USING;p;m;i;mask
      :Access Public Shared
      ⍝ returns [;1] pid [;2] process name of any processes that were not killed
      r←0 2⍴0 ''
      :If 0≠⍴kids←ListProcesses Exe ⍝ All child processes using the exe
          :If IsWin
              ⎕USING←'System,system.dll'
              p←Diagnostics.Process.GetProcessById¨kids[;1]
              p.Kill
              ⎕DL 1
              :If 0≠⍴p←(~p.HasExited)/p
                  ⎕DL 1
                  p.Kill
                  ⎕DL 1
                  :If ∨/m←~p.HasExited
                      r←(kids[;1]∊m/p.Id)⌿kids
                  :EndIf
              :EndIf
          :Else
              mask←(⍬⍴⍴kids)⍴0
              :For i :In ⍳⍴mask
                  mask[i]←Shoot kids[i;1]
              :EndFor
              r←(~mask)⌿kids
          :EndIf
      :EndIf
    ∇

    ∇ r←ListProcesses procName;me;⎕USING;procs;unames;names;name;i;pn;kid;parent;mask
      :Access public shared
    ⍝ returns my child processes
    ⍝ procName is either '' for all children, or the name of a process
    ⍝ r[;1] - child process number (Id)
    ⍝ r[;2] - child process name
      me←GetCurrentProcessId
      r←0 2⍴0 ''
      procName←,procName
     
      :If IsWin
          ⎕USING←'System,system.dll'
     
          :If 0∊⍴procName ⋄ procs←Diagnostics.Process.GetProcesses''
          :Else ⋄ procs←Diagnostics.Process.GetProcessesByName⊂procName ⋄ :EndIf
     
          :If 0<⍴procs
              unames←∪names←procs.ProcessName
              :For name :In unames
                  :For i :In ⍳0+.=(,⊂name)⍳names
                      pn←name,(i≠0)/'#',⍕i
                      :Trap 0 ⍝ trap here just in case a process disappeared before we get to it
                          parent←⎕NEW Diagnostics.PerformanceCounter('Process' 'Creating Process Id'pn)
                          :If me=parent.NextValue
                              kid←⎕NEW Diagnostics.PerformanceCounter('Process' 'Id Process'pn)
                              r⍪←(kid.NextValue)name
                          :EndIf
                      :EndTrap
                  :EndFor
              :EndFor
          :EndIf
     
      :Else ⍝ Linux
      ⍝ unfortunately, Ubuntu (and perhaps others) report the PPID of tasks started via ⎕SH as 1
      ⍝ so, the best we can do at this point is identify processes that we tagged with ppid=
          mask←' '∧.=procs←' ',↑_SH'ps -eo pid,cmd | grep APLppid=',(⍕GetCurrentProcessId),(0<⍴procName)/' | grep ',procName
          mask∧←2≥+\mask
          procs←↓¨mask⊂procs
          mask←me≠tonum¨1⊃procs ⍝ remove my task
          procs←mask∘/¨procs[1 2]
          :If 0<⍴procName
              mask←∨/¨(procName,' ')∘⍷¨(2⊃procs),¨' '
              mask>←∨/¨'grep '∘⍷¨2⊃procs ⍝ remove procs that are for the searches
              procs←mask∘/¨procs
          :EndIf
          r←↑[0.1]procs
      :EndIf
    ∇

    ∇ r←Kill;res
      :Access public instance
      r←0
      :Trap 0
          :If IsWin
              Proc.Kill
              ⎕DL 0.2
          :Else
              {}_SH'kill -3 ',⍕Proc.Id ⍝ issue strong interrupt
              {}⎕DL 2 ⍝ wait a couple seconds for it to react
              :If ~Proc.HasExited←0∊⍴res←_SH'ps h -p ',(⍕Proc.Id),' -o cmd'
                  Proc.HasExited∨←∨/'<defunct>'⍷⊃,/res
              :EndIf
          :EndIf
          r←Proc.HasExited
      :EndTrap
    ∇

    ∇ r←Shoot Proc;MAX;res
      MAX←100
      r←0
      :If 0≠⎕NC⊂'Proc.HasExited'
          :Repeat
              :If ~Proc.HasExited
                  :If IsWin
                      Proc.Kill
                      ⎕DL 0.2
                  :Else
                      {}_SH'kill -3 ',⍕Proc.Id ⍝ issue strong interrupt
                      {}⎕DL 2 ⍝ wait a couple seconds for it to react
                      :If ~Proc.HasExited←0∊⍴res←_SH'ps h -p ',(⍕Proc.Id),' -o cmd'
                          Proc.HasExited∨←∨/'<defunct>'⍷⊃,/res
                      :EndIf
                  :EndIf
              :EndIf
              MAX-←1
          :Until Proc.HasExited∨MAX≤0
          r←Proc.HasExited
      :EndIf
    ∇

    ∇ r←HasExited
      :Access public instance
      :If IsWin
          r←Proc.HasExited
      :Else
          :If ~r←0∊⍴res←_SH'ps h -p ',(⍕Proc.Id),' -o cmd'
              r∨←∨/'<defunct>'⍷⊃,/res
          :EndIf
      :EndIf
    ∇

    ∇ r←IsRunning args;⎕USING;start;exe;pid;proc;diff
      :Access public shared
      ⍝ args - pid {exe} {startTS}
      r←0
      args←eis args
      (pid exe start)←3↑args,(⍴args)↓0 ''⍬
      :If IsWin
          ⎕USING←'System,system.dll'
          :Trap 0
              proc←Diagnostics.Process.GetProcessById pid
              r←1
          :Else
              :Return
          :EndTrap
          :If ''≢exe
              r∧←exe≡proc.ProcessName
          :EndIf
          :If ⍬≢start
              diff←|-/#.DFSUtils.DateToIDN¨start(proc.StartTime.(Year Month Day Hour Minute Second Millisecond))
              r∧←diff≤24 60 60 1000⊥0 1 0 0÷×/24 60 60 1000 ⍝ consider it a match within a 1 minute window
          :EndIf
      :Else
          ∘∘∘ ⍝!!!TODO write Unix version
      :EndIf
    ∇

    ∇ r←Stop pid;proc
      :Access public shared
    ⍝ attempts to stop the process with processID pid
      :If IsWin
          ⎕USING←'System,system.dll'
          :Trap 0
              proc←Diagnostics.Process.GetProcessById pid
          :Else
              r←1
              :Return
          :EndTrap
          proc.Kill
          {}⎕DL 0.5
          r←~##.APLProcess.IsRunning pid
      :Else
          ∘∘∘ ⍝!!!TODO write unix
      :EndIf
    ∇

    ∇ r←_SH cmd
      r←{0::'' ⋄ ⎕SH ⍵}cmd
    ∇

    :class Time
        :field public Year
        :field public Month
        :field public Day
        :field public Hour
        :field public Minute
        :field public Second
        :field public Millisecond

        ∇ make ts
          :Implements constructor
          :Access public
          (Year Month Day Hour Minute Second Millisecond)←7↑ts
          ⎕DF(⍕¯2↑'00',⍕Day),'-',((12 3⍴'JanFebMarAprMayJunJulAugSepOctNovDec')[⍬⍴Month;]),'-',(⍕100|Year),' ',1↓⊃,/{':',¯2↑'00',⍕⍵}¨Hour Minute Second
        ∇
    :endclass


:EndClass
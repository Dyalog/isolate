:Namespace ll
⍝ Parallel Extensions

    (⎕IO ⎕ML ⎕WX)←1 1 3

    Each←{⍺←⊢ ⋄ ⍺ (⍺⍺ EachX ⍬) ⍵}

    ∇ r←{left}(fns EachX iss)right;dyadic;fn;cb;n;counts;shape;ni;i;count;done;failed;next;callbk;expr;z;PF;cblarg;cancelled;cbprovided;noIso;cr
    ⍝ IÏ using queueing on persistent Isolates:
    ⍝
    ⍝ iss is a list of refs to pre-existing isolates to use
    ⍝     or if scalar, processors×processes clones will be made
    ⍝
    ⍝ fns is either:
    ⍝     a simple char vec name of function expected to be in supplied isolates
    ⍝     a nested vec of two fn names, in which case 2nd name is a progress callback
    ⍝     use empty callback fn for default display
     
      :If dyadic←2=⎕NC'left' ⍝ Scalar extension
          :If 1=×/⍴left ⋄ left←(⍴right)⍴left
          :ElseIf 1=×/⍴right ⋄ right←(⍴left)⍴right
          :EndIf
      :EndIf
     
      :If noIso←0=≢iss ⋄ iss←⊂'' ⋄ :EndIf ⍝ No isolate passed
     
      :If 3=⎕NC'fns'          ⍝ A real function?
          :If 1=⍴⍴cr←⎕CR'fns' ⋄ fns←cr''⊣⎕EX'fns' ⋄ ⍝ primitive?
          :Else
              :If noIso ⋄ iss←⎕NS'' ⋄ :EndIf
              fn←⊃(,iss).⎕FX⊂⎕CR'fns'
              fns←fn'' ''⊣⎕EX'fns'
          :EndIf
     
      :EndIf
     
      :If 0=⍴⍴iss ⍝ If scalar, clone
          iss←#.isolate.{New¨(×/Config¨'processors' 'processes')⍴⍵}iss
      :EndIf
     
      :If cbprovided←2=≡fns   ⍝ We MAY have a callback function
          (fn cb cblarg)←3↑fns,'' ''
          cbprovided←cb∨.≠' ' ⍝ We DO have a callback function
          cblarg,←(0=≢cblarg)/'ll.Each Progress - ',(⍕fn),' (',(⍕×/⍴right),')'
      :Else ⍝ No callback function defined
          fn←fns ⋄ (cb cblarg)←'' 'll.Each Progress'
      :EndIf
     
      :If 0=⍴cb  ⍝ Default Progress Form
          :If PEACHForm cblarg(≢iss)(×/⍴right)
              cb←'PEACHUpdate'
          :EndIf
      :EndIf ⍝ Default
     
      :If cbprovided
          callbk←(⊃⎕RSI)⍎cb
      :Else
          callbk←⍎cb,(0=≢cb)/'{0}'
      :EndIf
     
      ni←≢iss
      shape←⍴right
      n←⍴right←,right ⋄ :If dyadic ⋄ left←,left ⋄ :EndIf
      counts←ni⍴0 ⋄ done←failed←n⍴count←0
      r←n⍴⎕NULL
     
      expr←(dyadic/'(next⊃left) '),'iso.{',(dyadic/'⍺ '),'(',(⍕fn),') ⍵} next⊃right'
      cancelled←0
      :If 1=≢iss ⍝ Only one: do it in main thread
          z←1 run1iso⊃iss
      :Else
          z←⎕TSYNC(⍳ni)run1iso&¨iss
      :EndIf
      ⎕SIGNAL cancelled/6
    ∇

    ∇ r←PEACHForm(caption nprocs nitems);p;labels;pos;pb;n
    ⍝ Make a progress form with a progress bar per process and one for the total
     
      :Trap 0
          r←1⊣'PF'⎕WC'Form'caption('Coord' 'Pixel')('Size'((40+25×nprocs)800))('Border' 3)
      :Else ⋄ →r←0 ⍝ Unable to create a form
      :EndTrap
      PF.texts←PF.bars←(1+nprocs)⍴PF
      labels←({'Iso #',⍕⍵}¨⍳nprocs),⊂'Total'
     
      :For p :In ⍳1+nprocs
          pos←10+25×p-1
          ('PF.L',⍕p)⎕WC'Label'(p⊃labels)(pos 20)(⍬ 60)
          (n←'PF.T',⍕p)⎕WC'Label' '0'(pos 70)(⍬ 30)('justify' 'right')
          PF.texts[p]←⍎n
          (n←'PF.PB',⍕p)⎕WC'ProgressBar'((pos+3)110)(⍬ 655)('Limits'(0 nitems))
          PF.bars[p]←⍎n
      :EndFor
      2 ⎕NQ'.' 'Flush'
    ∇

    ∇ {abort}←cap PEACHUpdate arg
      :Trap abort←0
          PF.texts.Caption←⍕¨arg
          PF.bars.Thumb←arg
      :Else
          abort←1 ⍝ User killed the GUI
      :EndTrap
    ∇

    ∇ z←isoix run1iso iso;next
     ⍝ drive isolate #iso until we are done
     ⍝ NB semi-globals from EachX: r n count counts bclarg callbk cancelled
     
      z←0
      :While n≥next←count←count+1 ⍝ no more to do
          r[next]←⊂⍎expr
          counts[isoix]+←1
          z←{0::failed[⍵]←1 ⋄ done[⍵]←1⊣+r[⍵]}next ⍝ Reference it
          :If cblarg callbk counts,count⌊n
              →0⊣z←''⊣cancelled←1
          :EndIf
      :EndWhile
    ∇

:EndNamespace

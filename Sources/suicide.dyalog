:Class suicide
    ∇ inst←New data;whence
      :Access public shared
      whence←⍬⍴⎕RSI
      inst←whence.⎕NEW ⎕THIS
      inst.(whence data)←whence data
    ∇

    ∇ coroner
      :Implements destructor
      (fn arg)←data
      (whence.⍎fn)arg
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

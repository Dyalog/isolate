 r←x qsignal y
 ⍝ To help signal an error that will not terminate a dfn capsule
 y←(y 86)[y>999] ⍝ Use 86 for interrupts and CONGA ERRORS
 ⎕SIGNAL⊂('EN'y)('EM'x)('Message'x)

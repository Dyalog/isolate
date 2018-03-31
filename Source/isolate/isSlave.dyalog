 r←isSlave ⍝ Return 1 if the current process is an isolate server
 r←'isolate'≡RPCServer.GetEnv'isolate'

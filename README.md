# haskell-freer-effects-weirdness


The intent of this is just to host an example of an odd behavior we came accross. Although, now I understand what was happening, at the time I was under the impression that order didn't matter for the handlers outside of handler A coming before handler B if A created a B.

Turns out the problem was because we had 2 effects that translated/reinterpreted to the same effect we had to call that handler multiple times because we had additional effects of the same type on the stack.

```haskell
   handlerA :: eff a -> eff c
   handlerB :: eff b -> eff c
   
-- means we needed to use our handlers like this
  runM
    $ handlerC
    $ handlerB
    $ handlerC
    $ handlerA (\function -> ...)```

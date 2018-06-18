module Demo (

) where
---

import Control.Monad.Freer
import Data.Function ((&))



-- magic effect
data Magic a where
  DoMagic :: String -> Magic ()



-- Printer Effect
data Printer a where
  PrintHello :: Printer ()
  PrintAny :: String -> Printer ()

printHello :: (Member Printer effs) => Eff effs ()
printHello = send PrintHello

printAny :: (Member Printer effs) => String -> Eff effs ()
printAny msg = send $ PrintAny msg

-- Bell Effect
data Bell a where
  RingBell :: Bell ()

ringBell :: (Member Bell effs) => Eff effs ()
ringBell = send RingBell

-- Magic Handler
handleMagic :: (LastMember IO effs) => Eff (Magic ': effs) a -> Eff effs a
handleMagic = interpretM $ \case (DoMagic x) -> print x

-- Printer Handler
handlePrinter :: Eff (Printer ': effs) a -> Eff ( Magic ': effs) a
handlePrinter = translate impl
  where
    impl :: Printer a -> Magic a
    impl (PrintHello) = DoMagic "Hello"
    impl (PrintAny msg) = DoMagic msg

-- Bell Handler
handleBell :: Eff (Bell ': effs) a -> Eff (Magic ': effs) a
handleBell = translate impl
  where
    impl :: Bell a -> Magic a
    impl (RingBell) = DoMagic "The bell has been tolled"

-- runner, this works
runNoiseMaker =
  runM
    $ handleMagic
    $ handleBell
    $ handleMagic
    $ handlePrinter noiseMaker

-- this doesn't work
-- runNoiseMaker =
--   runM
--     $ handleMagic
--     $ handlePrinter
--     $ handleBell noiseMaker

noiseMaker :: Members '[Printer, Bell] effs => Eff effs ()
noiseMaker = do
  printHello
  ringBell



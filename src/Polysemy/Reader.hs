{-# LANGUAGE TemplateHaskell #-}

module Polysemy.Reader
  ( -- * Effect
    Reader (..)

    -- * Actions
  , ask
  , asks
  , local

    -- * Interpretations
  , runReader
  , runInputAsReader
  ) where

import Polysemy
import Polysemy.Input


------------------------------------------------------------------------------
-- | An effect corresponding to 'Control.Monad.Trans.Reader.ReaderT'.
data Reader i m a where
  Ask   :: Reader i m i
  Local :: (i -> i) -> m a -> Reader i m a

makeSem ''Reader


asks :: Member (Reader i) r => (i -> j) -> Sem r j
asks f = f <$> ask
{-# INLINABLE asks #-}


------------------------------------------------------------------------------
-- | Run a 'Reader' effect with a constant value.
runReader :: i -> Sem (Reader i ': r) a -> Sem r a
runReader i = interpretH $ \case
  Ask -> pureT i
  Local f m -> do
    mm <- runT m
    raise $ runReader_b (f i) mm
{-# INLINE runReader #-}

runReader_b :: i -> Sem (Reader i ': r) a -> Sem r a
runReader_b = runReader
{-# NOINLINE runReader_b #-}


------------------------------------------------------------------------------
-- | Transform an 'Input' effect into a 'Reader' effect.
runInputAsReader :: Sem (Input i ': r) a -> Sem (Reader i ': r) a
runInputAsReader = reinterpret $ \case
  Input -> ask
{-# INLINE runInputAsReader #-}


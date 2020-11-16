module Repository (get, put, del) where

import Control.Monad.Except (liftIO)
import Data.ByteString ( ByteString)
import Data.Aeson (Value)
import Servant
import qualified Redis
import qualified Mongo

get :: ByteString -> Handler Value
get file = do
  mbValue <- liftIO $ Redis.getValue file
  case mbValue of
    Just value -> pure value
    Nothing    -> do 
        value <- liftIO (Mongo.getValue file) >>= maybe error pure
        liftIO (Redis.putValue file value) >>= maybe error pure
        pure value
  where
    error = throwError err404

put :: ByteString ->  Value -> Handler ()
put val file = liftIO $ Mongo.putValue file val 

del :: ByteString -> Handler ()
del file = do
  liftIO (Mongo.delValue file) >>= maybe error pure
  liftIO $ Redis.delValue file 
  pure ()
  where
    error = throwError err404
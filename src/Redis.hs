module Redis (putValue, getValue, delValue) where

import Control.Monad (void)
import qualified Database.Redis as Redis
import Data.Aeson (Value, encode, decode)
import Data.ByteString.Lazy ( toStrict, fromStrict)
import Data.ByteString (ByteString)
import Prelude hiding (take)

putValue :: ByteString -> Value -> IO (Maybe ())
putValue file val = do
  conn <- Redis.checkedConnect Redis.defaultConnectInfo
  let dbData = toStrict $ encode val
  status <- Redis.runRedis conn $ Redis.set file dbData
  print status
  let value = either (const Nothing) Just status
  pure $ void value

getValue :: ByteString -> IO (Maybe Value)
getValue file = do
  conn <- Redis.checkedConnect Redis.defaultConnectInfo
  res <- Redis.runRedis conn $ Redis.get file
  print res
  let value = either (const Nothing) id res
  pure $ (decode . fromStrict) =<< value

delValue :: ByteString -> IO (Maybe ())
delValue file = do
  conn <- Redis.checkedConnect Redis.defaultConnectInfo
  res <- Redis.runRedis conn $ Redis.del [file]
  print res
  let value = either (const Nothing) Just res
  pure $ void value
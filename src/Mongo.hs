{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
module Mongo (putValue, getValue, delValue) where
import Database.MongoDB
import qualified Data.Aeson as Aeson
import Data.ByteString.Lazy ( toStrict, fromStrict)
import Data.ByteString ( ByteString)
import Prelude hiding (length)
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8)

putValue :: Aeson.Value -> ByteString -> IO ()
putValue value file = runDB file (put value)

getValue :: ByteString -> IO (Maybe Aeson.Value)
getValue file = runDB file get

delValue :: ByteString -> IO (Maybe ())
delValue file = runDB file del

runDB :: Show a => ByteString -> (Text ->  Action IO a) -> IO a
runDB file action = do
   pipe <- connect (host "127.0.0.1")
   e <- access pipe master "server" (action $ decodeUtf8 file)
   close pipe
   print e
   pure e

put :: Aeson.Value -> Text -> Action IO ()
put value file = do
  let dbData = val . Binary . toStrict $ Aeson.encode value
  insert "table" [file =: dbData]
  pure ()

findBinary :: Text -> Action IO (Maybe Binary)
findBinary file = do
  res <- findOne (select [] "table")
  pure $ case res of
     Nothing -> Nothing
     Just doc -> cast' (valueAt file doc) :: Maybe Binary

get :: Text -> Action IO (Maybe Aeson.Value)
get file = do
   dbData <- findBinary file
   pure $ (Aeson.decode . fromStrict) =<< getBinary dbData
   where 
      getBinary (Just (Binary value)) = Just value
      getBinary Nothing = Nothing

del :: Text -> Action IO (Maybe ())
del file = do
   dbData <- findBinary file
   case dbData of
      Nothing -> pure Nothing
      Just body -> do
         delete (select [file := val body] "table")
         pure $ Just ()
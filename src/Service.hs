{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Service (get, put, del) where

import Control.Monad.Except (liftIO)
import Data.Aeson (Value, decode, encode)
import qualified Data.ByteString.Lazy as ByteString
import Data.Maybe (fromMaybe)
import Servant
import System.Directory (createDirectoryIfMissing, doesFileExist, removePathForcibly)

filePath :: FilePath -> FilePath
filePath fileName = "files/" ++ fileName

createDir :: Handler ()
createDir = liftIO $ createDirectoryIfMissing True "files"

get :: FilePath -> Handler Value
get file = do
  createDir
  exists <- liftIO . doesFileExist $ filePath file
  if exists
    then do
      json <- liftIO (ByteString.readFile (filePath file))
      let str = decode json :: Maybe Value
      return . fromMaybe "" $ str
    else throwError err404

put :: FilePath -> Value -> Handler ()
put file req = do
  createDir
  liftIO . ByteString.writeFile (filePath file) $ encode req

del :: FilePath -> Handler ()
del file = do
  createDir
  exists <- liftIO . doesFileExist $ filePath file
  if exists
    then liftIO $ removePathForcibly (filePath file)
    else throwError err404
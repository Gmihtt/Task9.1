{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Controller (app) where

import qualified Servant.API.Verbs as Verbs
import Data.Aeson (Value)
import Servant
import Data.Text.Encoding (encodeUtf8)
import qualified Data.Text as T
import Repository ( get, put, del )

type MyPut = Verbs.Verb PUT 201

type API = 
      "storage" :> Capture "my-file" String :> (Get '[JSON] Value
       :<|> ReqBody '[JSON] Value :> MyPut '[JSON] ()
       :<|> DeleteNoContent '[JSON] ())

api :: Proxy API
api = Proxy

server :: Server API 
server file = get bFile :<|> put bFile :<|> del bFile
  where
    bFile = encodeUtf8 $ T.pack file

app :: Application
app = serve api server

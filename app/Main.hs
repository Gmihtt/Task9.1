module Main where

import Network.Wai.Handler.Warp (run)
import Controller (app)

main :: IO ()
main =
  run 8080 app

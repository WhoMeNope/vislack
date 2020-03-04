{-# LANGUAGE OverloadedStrings #-}

module Main where

import System.Environment (lookupEnv)
import Control.Monad.Trans.Reader
import Data.Text (pack)
import qualified Web.Slack as Slack
import qualified Web.Slack.Api as Api

tokenEnvKey = "SLACK_TOKEN"

main :: IO ()
main = do
  -- Try getting slack token from env
  maybeToken <- lookupEnv tokenEnvKey
  case maybeToken of
    Nothing -> putStrLn "No slack token found in env."

    -- If a token was found, start the app
    Just token -> do
      putStrLn "Got slack token."

      slackConfig <- Slack.mkSlackConfig (pack token)

      putStrLn "Running app"
      _ <- flip runReaderT slackConfig (Slack.apiTest Api.mkTestReq)
      putStrLn "Succesfully ran app"

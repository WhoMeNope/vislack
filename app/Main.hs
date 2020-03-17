{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Main where

import System.Environment (lookupEnv)
import System.IO (readFile)
import System.Directory (getHomeDirectory)
import Control.Monad (mapM_)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Reader
import Data.Text (pack, unpack)
import Text.JSON.Generic

import Web.Slack.Conversation
import qualified Web.Slack as Slack

data Config = Config
    { slack_token  :: String
    } deriving (Show, Data, Typeable)

tokenEnvKey = "SLACK_TOKEN"
configPath = "/.slack-term"

main :: IO ()
main = do
  -- Try getting slack token from env
  maybeToken <- lookupEnv tokenEnvKey
  case maybeToken of
    Nothing -> do
      putStrLn "No slack token found in env."

      -- Read config file
      home <- getHomeDirectory
      configFile <- readFile (home <> configPath)
      let config = decodeJSON configFile :: Config
      putStrLn "Got slack token from config file."

      runApp (slack_token config)

    -- If a token was found, start the app
    Just token -> do
      putStrLn "Got slack token from env."

      runApp token

runApp :: String -> IO ()
runApp token = do
  slackConfig <- Slack.mkSlackConfig (pack token)
  _ <- flip runReaderT slackConfig app
  return ()

app :: ReaderT Slack.SlackConfig IO ()
app = do
  eRes <- Slack.usersConversations
  lift $ case eRes of
    Left error -> putStrLn $ show error
    Right listResp -> do
      let channels = listRspChannels listResp
      mapM_ (putStrLn . unpack . conversationId) channels
  return ()

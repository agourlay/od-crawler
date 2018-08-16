{-# LANGUAGE OverloadedStrings #-}

module Storage where

import qualified System.Directory as SD
import qualified System.IO as SI
import qualified Data.HashSet as HS
import qualified Data.Text as T
import qualified Data.Text.IO as TIO

createFileIfNotExist :: String -> IO ()
createFileIfNotExist filePath = do
  exists <- SD.doesFileExist filePath
  if exists then
    pure ()
  else
    SI.writeFile filePath ""

fileNameForURL :: String -> String
fileNameForURL urlS =
  let url = T.pack urlS
      noTrailingSlash = T.dropWhileEnd (== '/')
      afterProtocol = last . T.splitOn "://"
      cleaned = T.replace "/" "-"
      composed = T.unpack $ (cleaned . afterProtocol . noTrailingSlash) url
   in composed ++ ".txt"

-- https://www.stackage.org/haddock/lts-11.17/unordered-containers-0.2.9.0/Data-HashSet.html
-- A bloom filter should actually be enough to reduce memory footprint
loadPersistedResultsForURL :: String -> IO (HS.HashSet T.Text)
loadPersistedResultsForURL filePath = do
  fileContent <- TIO.readFile filePath
  let entries = fmap (last . T.splitOn " --> ") (T.lines fileContent)
  let populatedSet = foldr HS.insert HS.empty entries
  pure populatedSet
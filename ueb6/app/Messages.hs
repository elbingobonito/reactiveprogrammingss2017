{-# LANGUAGE OverloadedStrings #-}

module Messages where

import qualified Data.Map.Lazy as M
import Data.Aeson
import OT

data ClientMessage = ClientEdit Int TextOperation Cursor

data ServerMessage = RemoteEdit TextOperation (M.Map Int Cursor)
                   | Ack
                   | HelloGuys

instance FromJSON TextAction where
  parseJSON (Number x) = do
    n <- parseJSON (Number x)
    return $ 
      if n < 0 then Delete $ abs n
      else Retain n 
  parseJSON (String t) = do
    c <- parseJSON (String t)
    return $ Insert c

instance FromJSON TextOperation where
  parseJSON (Array a) = do
    ops <- parseJSON (Array a)
    return $ TextOperation ops

instance FromJSON ClientMessage where
  parseJSON (Object o) = ClientEdit
    <$> o .: "rev"
    <*> o .: "op"
    <*> o .: "cursor" 

instance ToJSON TextAction where
  toJSON (Retain n) = toJSON (n :: Int)
  toJSON (Delete n) = toJSON (-n :: Int)
  toJSON (Insert c) = toJSON c

instance ToJSON TextOperation where
  toJSON (TextOperation as) = toJSON $ map toJSON as

instance ToJSON ServerMessage where
  toJSON Ack = toJSON ("ack" :: String)
  toJSON HelloGuys = toJSON ("helloguys" :: String)
  toJSON (RemoteEdit op cursors) = object ["op" .= toJSON op, 
    "cursors" .= cursors'] where cursors' = toJSON $ M.elems cursors 
 

{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Snap
import           Snap.Snaplet.Session.Backends.CookieSession
import qualified Data.ByteString.Char8 as B
import           Snap.Util.FileServe
import           App
import           Root
import           Display
import           QuizData


--Initializes the app to use Session Snaplet
appInit :: B.ByteString -> B.ByteString -> B.ByteString -> [QuizData] -> SnapletInit App App
appInit header footer about quizdata = makeSnaplet "myapp" "Sample Page" Nothing $ do
    ss <- nestSnaplet "session" sess $ initCookieSessionManager "session.txt" "_session" (Just 3600)
    addRoutes [ ("/", sessionHandler header footer)
              , ("about", writeBS about)
              , ("img", serveDirectory "img")
              , ("quizdata", writeBS $ B.pack $ displayQuizList quizdata)
              --, ("quiz1/question1", writeBS $ B.pack $ display (head question) (last question) )
              ]
    return $ App ss
    


--Main function reads html files and calls session functions
main :: IO ()
main = do
    header <- B.readFile "./src/header.html"
    footer <- B.readFile "./src/footer.html"
    about <- B.readFile "./src/about.html"
    quizdata <- readit "./src/quizdata.txt"
    quizes <- createQuizes
    serveSnaplet defaultConfig $ appInit header footer about quizdata
    
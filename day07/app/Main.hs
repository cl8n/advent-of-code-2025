{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Exception (catch)
import Data.ByteString.Char8 qualified as ByteString
import Data.List qualified as List
import Data.Map (Map)
import Data.Map qualified as Map
import Data.Set (Set)
import Data.Set qualified as Set
import GHC.IO.Exception (IOException)
import Network.HTTP.Simple

main :: IO ()
main = do
  input <- downloadAndCachePuzzle "https://adventofcode.com/2025/day/7/input"
  let inputLines = lines input
  putStrLn "Part 1:"
  print $ part1 inputLines
  putStrLn "Part 2:"
  print $ part2 inputLines

downloadAndCachePuzzle :: String -> IO String
downloadAndCachePuzzle url =
  catch
    (readFile "input")
    ( const
        ( do
            puzzle <- downloadPuzzle url
            writeFile "input" puzzle
            return puzzle
        ) ::
        IOException -> IO String
    )

downloadPuzzle :: String -> IO String
downloadPuzzle url = do
  session' <- ByteString.readFile "../session"
  let session = ByteString.dropWhileEnd (== '\n') session'
  request' <- parseRequest url
  let request = setRequestHeaders [("Cookie", session)] request'
  response <- httpBS request
  return $ ByteString.unpack (getResponseBody response)

-- Input parsing

positionSetFromLine :: String -> Set Int
positionSetFromLine =
  Set.fromDistinctAscList . List.findIndices (\char -> char == 'S' || char == '^')

-- Part 1

part1 :: [String] -> Int
part1 inputLines =
  case map positionSetFromLine inputLines of
    (beams : splittersList) -> fst $ foldl' sumSplitsAndSplitBeams (0, beams) splittersList
    _ -> 0

sumSplitsAndSplitBeams :: (Int, Set Int) -> Set Int -> (Int, Set Int)
sumSplitsAndSplitBeams (splitCount, beams) splitters =
  ( splitCount + Set.size (Set.intersection beams splitters),
    splitBeams beams splitters
  )

splitBeams :: Set Int -> Set Int -> Set Int
splitBeams beams splitters =
  Set.union (Set.difference beams splitters) $
    Set.fromList $
      concatMap
        (\x -> [x - 1, x + 1])
        (Set.intersection beams splitters)

-- Part 2

part2 :: [String] -> Int
part2 inputLines =
  case map positionSetFromLine inputLines of
    (beams : splittersList) -> sum $ foldl' splitBeamsPart2 (Map.fromSet (const 1) beams) splittersList
    _ -> 1

splitBeamsPart2 :: Map Int Int -> Set Int -> Map Int Int
splitBeamsPart2 beams splitters =
  Map.fromListWith (+) $
    Map.toList (filterByKey (`Set.notMember` splitters) beams)
      ++ concatMap
        (\(k, x) -> [(k - 1, x), (k + 1, x)])
        (Map.toList (filterByKey (`Set.member` splitters) beams))

filterByKey :: (k -> Bool) -> Map k a -> Map k a
filterByKey predicate = Map.filterWithKey (\k _ -> predicate k)

#!/usr/bin/env runhaskell

import Control.Concurrent (threadDelay)
import Data.Function.Memoize (memoize)
import Data.Map (fromList)
import System.Environment (getArgs)
import Text.Format (format)
import Graphics.Gnuplot.Simple (plotPathStyle, plotPathsStyle,
                                Attribute(Title, XLabel, YLabel, XRange, PNG),
                                PlotStyle, defaultStyle,
                                lineSpec, LineSpec(CustomStyle),
                                LineAttr(LineTitle),
                                plotFunc3d)

import TVToolBox

----------
-- Main --
----------

main :: IO ()
main = do
  let
    sA = 0.5
    nA = 10
    k = defaultK
    resolution = defaultResolution       -- number of bins in the distribution

  -- Calculate corresponding count
  let
    xA = strengthToCount sA nA
  putStrLn ("xA = " ++ show xA)

  -- Generate corresponding distribution
  let
    dA = genDist sA nA k
    dAbeta = fromList [(p, prob_beta nA sA k p) | p <- [0.0,0.01..1.0]]
    dAonly_beta = fromList [(p, prob_only_beta nA sA k p) | p <- [0.0,0.01..1.0]]

  putStrLn ("dA: " ++ (showDist dA))
  putStrLn ("dAbeta: " ++ (showDist dAbeta))
  putStrLn ("dAonly_beta: " ++ (showDist dAonly_beta))

  let lineTitle name strength count =
          format "{0}.tv(s={1}, n={2}, k={3})"
          [name, show strength, show count, show k]
  plotDists
    [(lineTitle "A" sA nA, dA),
     (lineTitle "Abeta" sA nA, dAbeta),
     (lineTitle "Aonly_beta" sA nA, dAonly_beta)]
    "A, Abeta, Aonly_beta" False False

  -- Plot in 3d the pdf varying k
  let
    mink = 1
    maxk = 1000
    strs = [show sA, show nA, show mink, show maxk]
  plotFunc3d [Title (format "pdf(<s={0},n={1}>) k=[{2}..{3}]" strs),
              PNG (format "pdf_s_{0}_n_{1}_k_{2}_{3}.png" strs)]
    [] [0.0,0.001..1.0] [mink..maxk] (\p k -> pdf_beta nA sA k p)
  -- plotFunc3d [] [] [0.0,0.001..1.0] [1..500] (\p k -> pdf_only_beta nA sA k p)

  threadDelay 100000000000

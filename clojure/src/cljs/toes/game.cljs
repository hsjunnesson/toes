(ns toes.game
  "Functions for manipulating the current game."
  (:require [toes.board :as board]))

(def current-game
  "The current game, as an atom of a vector of boards.
   Each board, front to back, is a history of the each move."
  (atom [board/empty-board]))

(defn current-board
  "Returns the current board out of the game history."
  []
  (last @current-game))

(defn move!
  "Places the next mark at the specified index.
   Returns the resulting board, or nil if unable to place the mark."
  [index]
  (let [current (current-board)
        mark (board/next-turn current)
        next (board/place current index mark)
        legal? (and (board/legal-place? current index mark)
                    (not (board/winner current)))]
    (if legal?
      (do
        (swap! current-game
               conj
               next)
        next))))

(defn new-game!
  "Resets the current game to a fresh board."
  []
  (reset! current-game
          [board/empty-board]))


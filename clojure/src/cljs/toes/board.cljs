(ns toes.board)

(def empty-board
  "An empty board - the starting position."
  (vec (repeat 9 :-)))

(def x-mark
  "The symbol used for the x mark."
  :x)

(def o-mark
  "The symbol used for the o mark."
  :o)

(def empty-mark
  "The symbol used for the empty mark."
  :-)

(def winners
  "The defined set of winning positions."
  [[0 1 2]
   [3 4 5]
   [6 7 8]
   [0 3 6]
   [1 4 7]
   [2 5 8]
   [0 4 8]
   [2 4 6]])

(defn mark-to-string
  "A human readable representation of a mark."
  [mark]
  (case mark
    :- " "
    :o "O"
    :x "X"))

(defn mark-at-index
  "Returns the mark at"
  [board index]
  (board index))

(defn place
  "Places a mark :x or :o on a board at a specific index."
  [board index mark]
  (assoc board index mark))

(defn winner
  "Returns the winner :x or :o or nil if no winner."
  [board]
  (first
   (filter #(or (= :x %)
                (= :o %))
           ;; For each winning position, check if its all the same mark
           (for [positions winners]
             (condp = (distinct (map #(board %) positions))
               [:x] :x
               [:o] :o
               nil)
             ))))

(defn draw?
  "Whether the board is a draw."
  [board]
  (and (not (winner board))
       (not-any? #{:-} board)))

(defn next-turn
  "Displays who's turn it is, returns :x or :o."
  [board]
  (if (> (count (filter #(= :x %) board))
         (count (filter #(= :o %) board)))
    :o
    :x))

(defn legal-place?
  "Predicate, whether a move is legal or not."
  [board index mark]
  (and
   (= mark (next-turn board))
   (= :- (board index))))


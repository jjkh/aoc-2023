(def scratchcard-grammar (peg/compile
  ~{
    :numbers (some (* (some " ") (number :d+)))
    :main (/ 
      (* "Card" :s+ (constant :num)(number :d+) 
         ":" (constant :winners)(group :numbers) 
         " |" (constant :numbers)(group :numbers))
      ,table)}))

(defn main [&]
  (with [f (file/open "day4.txt")]
    (def cards 
      (map |(first (peg/match scratchcard-grammar $)) (file/lines f)))

    (defn winner-count [card]
      (count |(has-value? (card :winners) $) (card :numbers)))
    (def card-wins
      (merge ;(seq [card :in cards] {(card :num) (winner-count card)})))

    (def pt1
      (sum (seq [count :in card-wins
                 :unless (= 0 count)]
        (math/exp2 (- count 1)))))
    (print "Part 1: " pt1)

    (defn pt2 []
      (def card-counts
        (merge ;(seq [card :in cards] {(card :num) 1})))

      (def card-nums (sort (keys card-counts)))
      (loop [num :in card-nums
             :let [count (card-counts num)]
             new-num :range [(+ num 1) (+ num 1 (card-wins num))]]
        (put card-counts new-num (+ (card-counts new-num) count)))
      (sum card-counts))
    (print "Part 2: " (pt2))))
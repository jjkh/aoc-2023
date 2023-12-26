(def cards-pt1 "23456789TJQKA")
(def card-values-pt1
  (from-pairs
    (seq [i :range [(length cards-pt1)]]
      [(keyword/slice cards-pt1 i (+ i 1)) (+ i 1)])))

(def cards-pt2 "J23456789TQKA")
(def card-values-pt2
  (from-pairs
    (seq [i :range [(length cards-pt2)]]
      [(keyword/slice cards-pt2 i (+ i 1)) (+ i 1)])))

(def round-grammar (peg/compile
  ~{:hand (5 (/ (<- (set ,cards-pt1)) ,keyword))
    :main (/ 
        (* (constant :hand) (group :hand) :s
        (constant :bet) (number :d+))
      ,table)}))

(defn rank-hand-pt1 [hand]
  (def counts
    (sorted (values (frequencies hand))))
  (cond
    # five of a kind
    (= (last counts) 5) 6
    # four of a kind
    (= (last counts) 4) 5
    # full house
    (and
      (= (last counts) 3)
      (= (length counts) 2)) 4
    # three of a kind
    (= (last counts) 3) 3
    # two pair
    (and
      (= (last counts) 2)
      (= (length counts) 3)) 2
    # one pair
    (= (last counts) 2) 1
    # default (all distinct)
    0))

(defn rank-hand-pt2 [hand]
  (def freqs (frequencies hand))

  (def j-val
    (if (has-key? freqs :J) (freqs :J) 0))
  (put freqs :J nil)
  (if (= (length freqs) 0)
    (put freqs :J 0))

  (def counts
    (sorted (values freqs)))

  (def max-val (+ (last counts) j-val))
      
  (cond
    # five of a kind
    (= max-val 5) 6
    # four of a kind
    (= max-val 4) 5
    # full house
    (and
      (= max-val 3)
      (= (length counts) 2)) 4
    # three of a kind
    (= max-val 3) 3
    # two pair
    (and
      (= max-val 2)
      (= (length counts) 3)) 2
    # one pair
    (= max-val 2) 1
    # default (all distinct)
    0))

(defn main [&]
  (with [f (file/open "day7.txt")]
    (def rounds
      (flatten (map (partial peg/match round-grammar) (file/lines f))))

    (defn compare-rounds? [rank-func card-vals r1 r2]
      (def r1-rank (rank-func (r1 :hand)))
      (def r2-rank (rank-func (r2 :hand)))

      (cond
        (= r1-rank r2-rank)
          (do
            (def hands 
              (partition 2 (interleave (r1 :hand) (r2 :hand))))
            (first 
              (seq [[c1 c2] :in hands
                    :when (not (= c1 c2))]
                (> (card-vals c1) (card-vals c2)))))
        (> r1-rank r2-rank)))
    (def compare-rounds-pt1?
      (partial compare-rounds? rank-hand-pt1 card-values-pt1))
    (def sorted-rounds-pt1
      (reverse (sorted rounds compare-rounds-pt1?)))
    
    (def compare-rounds-pt2?
      (partial compare-rounds? rank-hand-pt2 card-values-pt2))
    (def sorted-rounds-pt2
      (reverse (sorted rounds compare-rounds-pt2?)))

    (def pt1
      (sum
        (seq [i :in (range (length rounds))]
          (* (+ i 1) ((sorted-rounds-pt1 i) :bet)))))
    (print "Part 1: " pt1)

    (def pt2
      (sum
        (seq [i :in (range (length rounds))]
          # (pp [i ((sorted-rounds-pt2 i) :hand)])
          (* (+ i 1) ((sorted-rounds-pt2 i) :bet)))))
    (print "Part 2: " pt2)))

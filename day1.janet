(def grammar-pt1
  ~{:main (any (+ (number :d) 1))})

(def grammar-pt2 
  ~{
    :digit (+
      (/ (if "one" 1) 1)
      (/ (if "two" 1) 2)
      (/ (if "three" 1) 3)
      (/ (if "four" 1) 4)
      (/ (if "five" 1) 5)
      (/ (if "six" 1) 6)
      (/ (if "seven" 1) 7)
      (/ (if "eight" 1) 8)
      (/ (if "nine" 1) 9)
      (number :d))
    :main (any (+ :digit 1))})

(defn main [&]
  (with [f (file/open "day1.txt")]
    (def lines (map string/trimr (file/lines f)))
    (defn outer-nums [nums]
      (+ (* 10 (first nums)) (last nums)))
    (def pt1 
      (sum (map |(outer-nums (peg/match grammar-pt1 $)) lines)))
    (def pt2
      (sum (map |(outer-nums (peg/match grammar-pt2 $)) lines)))
    (print "Part 1: " pt1)
    (print "Part 2: " pt2)))

# (pp (peg/match grammar-pt1 "one1two2"))
# (pp (peg/match grammar-pt2 "one1two2"))
# (pp (peg/match grammar-pt2 "twone"))
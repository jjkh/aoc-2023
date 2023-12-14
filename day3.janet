(defn capture-label [line column x &opt column2]
  (default column2 (+ column 1))
  (def x-type 
    (case (type x)
      :number :num
      :sym))
  {:line line :col-left column x-type x :col-right (- column2 1)})

(def schematic-grammar (peg/compile
  ~{:number (* (line)(column)(number :d+)(column))
    :sym (* (line)(column)(<- (if-not (+ "." :s) 1)))
    :main (some (+ (/ (+ :number :sym) ,capture-label) 1))}))

(defn adjacent? [part-id sym]
  (def row-adjacent
    (<= (math/abs (- (part-id :line) (sym :line))) 1))
  (def col-adjacent
    (or
      (<= (math/abs (- (part-id :col-left) (sym :col-left))) 1)
      (<= (math/abs (- (part-id :col-right) (sym :col-left))) 1)))
  (and row-adjacent col-adjacent))

(defn adjacent? [part-id sym]
  (def row-adjacent
    (<= (math/abs (- (part-id :line) (sym :line))) 1))
  (def col-adjacent
    (or
      (<= (math/abs (- (part-id :col-left) (sym :col-left))) 1)
      (<= (math/abs (- (part-id :col-right) (sym :col-left))) 1)))
  (and row-adjacent col-adjacent))
  
(defn main [&]
  (with [f (file/open "day3.txt")]
    (def schematic 
      (peg/match schematic-grammar (file/read f :all)))
    
    (def symbols (filter |(nil? ($ :num)) schematic))
    (def part-ids (filter |(not (nil? ($ :num))) schematic))

    (def pt1 
      (sum 
        (seq [part-id :in part-ids
                 :when (any? (map |(adjacent? part-id $) symbols))]
          (part-id :num))))
    (print "Part 1: " pt1)

    (def pt2 
      (sum 
        (seq [sym :in symbols
                 :when (= (sym :sym) "*")
                 :let [gears (filter |(adjacent? $ sym) part-ids)]
                 :when (= (length gears) 2)]
          (product (map |(get $ :num) gears)))))
    (print "Part 2: " pt2)))
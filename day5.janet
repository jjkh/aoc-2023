(def almanac-grammar (peg/compile
  ~{
    :seeds (* "seeds: " (some (* (number :d+) (? " "))))
    :type (/ (<- :a+) ,keyword)
    :heading (* (constant :from) :type "-to-" (constant :to) :type " map:")
    :table (/ 
      (* (constant :dst)(number :d+) " " (constant :src)(number :d+) " " (constant :len)(number :d+))
      ,table)
    :main (/ 
      (* 
        (constant :seeds)(group :seeds) :s+
        (constant :mappings)(group (some (* (/ 
          (* :heading :s+
            (constant :ranges)(group (some (* :table :s+))))
          ,table)))))
      ,table)}))

(defn val-in-range? [map-range val]
  (def src-end 
    (+ (map-range :src) (map-range :len)))
  (and 
    (<= (map-range :src) val)
    (> src-end val)))

(defn map-data [mapping val]
  (var new-val val)
  (loop [map-range :in (mapping :ranges)
         :when (val-in-range? map-range val)]
    (set new-val (+ val (- (map-range :dst) (map-range :src)))))
  new-val)

(defn map-data2 [mapping start len]
  (var ranges @[])
  (def first-range (first (mapping :ranges)))
  (if (< start (first-range :src))
    (array/push ranges 
      [start (min (+ start len) (+ (first-range :src) (first-range :len)))]))

  (def end (+ start len))
  (seq [map-range :in (mapping :ranges)
         :when (> end (map-range :src))
         :when (<= start (+ (map-range :src) (map-range :len)))]
    (array/push ranges [(map-range :src) 0]))
  (pp ranges)
  ranges)

(defn main [&]
  (with [f (file/open "day5_test.txt")]
    (def almanac 
      (first (peg/match almanac-grammar (file/read f :all))))

    (sort-by |(get $ :src) (almanac :mappings))
    (var pt1-seeds (almanac :seeds))
    (loop [mapping :in (almanac :mappings)]
      (set pt1-seeds 
        (map |(map-data mapping $) pt1-seeds)))

    (def pt1 (min ;pt1-seeds))
    (print "Part 1: " pt1)

    (var pt2-seed-ranges (partition 2 (almanac :seeds)))
    (map-data2 (first (almanac :mappings)) 0 60)

    (def pt2 nil)
    (print "Part 2: " pt2)))
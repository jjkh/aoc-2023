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

(defn map-data [mapping val]
  (first (seq [m :in (mapping :ranges)
               :when (<= (m :src) val)
               :when (> (m :src-end) val)]
    (+ val (- (m :dst) (m :src))))))

(defn print-map [m]
  (print (m :from) "-to-" (m :to) ": ")
  (map 
    |(print ($ :src) "-" ($ :src-end) " => "($ :dst) "-" ($ :dst-end))
    (m :ranges))
  (print))

(defn normalize-mappings [mappings]
  (freeze (seq [m :in mappings]
    (var new-ranges (array/new (+ (length (m :ranges)) 2)))
    # loop through each range, filling gaps
    (var next-src 0)
    (loop [r :in (sorted-by |(get $ :src) (m :ranges))]
      # fill gap
      (if-not (= (r :src) next-src)
        (array/push new-ranges 
          {:src next-src
           :src-end (- (r :src) 1)
           :dst next-src
           :dst-end (- (r :src) 1)}))
      # add range
      (array/push new-ranges
        {:src (r :src)
         :src-end (+ (r :src) (r :len) -1) 
         :dst (r :dst)
         :dst-end (+ (r :dst) (r :len) -1)})
      (set next-src (+ (r :src) (r :len))))
    # add final range to infinity
    (array/push new-ranges 
      @{:src next-src :dst next-src :src-end math/inf :dst-end math/inf})
    (merge m {:ranges new-ranges}))))

(defn aggregate-mappings [mappings]
  (var final-mapping (first mappings))
  (loop [m :in (array/slice mappings 1)]
    (var new-ranges @[])
    (loop [fr :in (final-mapping :ranges)
            r :in (m :ranges)
           :when  (< (fr :dst) (r :src-end))
           :until (< (fr :dst-end) (r :src))]
      (def src (max (fr :dst) (r :src)))
      (def src-end (min (fr :dst-end) (r :src-end)))
      (def src-offset (- (fr :dst) (fr :src)))
      (def dst-offset (- (r :dst) (r :src)))
      (array/push new-ranges 
        {:src (- src src-offset)
         :src-end (- src-end src-offset)
         :dst (+ src dst-offset)
         :dst-end (+ src-end dst-offset)}))
    (set final-mapping (merge final-mapping 
      {:to (m :to) 
       :ranges (sorted-by |(get $ :src) new-ranges)})))
  (freeze final-mapping))

(defn main [&]
  (with [f (file/open "day5.txt")]
    (def almanac 
      (freeze (first (peg/match almanac-grammar (file/read f :all)))))

    (def nmaps (normalize-mappings (almanac :mappings)))
    (def seed-to-location (aggregate-mappings nmaps))

    (def pt1-locations 
      (map (partial map-data seed-to-location) (almanac :seeds)))

    (def pt1 (min ;pt1-locations))
    (print "Part 1: " pt1)

    (def pt2-seeds 
      (sorted-by 
        |($ :start) 
        (map 
          |{:start ($ 0) :end (- (sum $) 1)} 
          (partition 2 (almanac :seeds)))))

    (def possible-seeds 
      (flatten [
        (seq [s :in pt2-seeds
              r :in (seed-to-location :ranges)
              :when (> (r :src-end) (s :start))
              :when (<= (r :src) (s :end))]
          (r :src))
        (seq [s :in pt2-seeds]
          (s :start))]))

    (def pt2-locations 
      (map (partial map-data seed-to-location) possible-seeds))

    (def pt2 (min ;pt2-locations))
    (print "Part 2: " pt2)))
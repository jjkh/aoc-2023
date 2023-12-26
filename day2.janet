(def game-grammar (peg/compile
  ~{:num (number :d+)
    :color (+ 
      (/ "blue" :blue)
      (/ "green" :green)
      (/ "red" :red))
    :game-id (* "Game " :num ": ")
    :cube-count (/ 
      (* :num " " :color) 
      ,|{$1 $0})
    :handful (/ 
      (some (* :cube-count (? ", ")))
      ,|(merge ;$&))
    :main (/ 
      (* :game-id (some (* :handful (? "; "))))
      ,|{:id $0 :handfuls $&})}))

(defn min-cubes [handfuls]
  {:red   (max ;(map |(get $ :red 0)   handfuls))
   :green (max ;(map |(get $ :green 0) handfuls))
   :blue  (max ;(map |(get $ :blue 0)  handfuls))})

(defn exceeds-pt1-max [cubes]
    (def maxes {:red 12 :green 13 :blue 14})
    (or (< (maxes :red)   (cubes :red))
        (< (maxes :green) (cubes :green))
        (< (maxes :blue)  (cubes :blue))))

(defn main [&]
  (with [f (file/open "day2.txt")]
    (def games 
      (map |(first (peg/match game-grammar $)) (file/lines f)))
    # (pp games)
    (def min-cubes (seq [game :in games]
        {:id (game :id) :min-cubes (min-cubes (game :handfuls))}))

    (def pt1 
      (sum 
        (seq [game :in min-cubes
              :unless (exceeds-pt1-max (game :min-cubes))]
          (game :id))))

    (def pt2
      (sum (map |(product ($ :min-cubes)) min-cubes)))

    (print "Part 1: " pt1)
    (print "Part 2: " pt2)))`

(def game-grammar (peg/compile
  ~{:num (number (some :d))
    :color (+ 
      (/ "blue" :blue)
      (/ "green" :green)
      (/ "red" :red))
    :game-id (* "Game " :num ": ")
    :cube-count (/ 
      (* :num " " :color) 
      ,|{$1 $0})
    :handful (/ 
      (some (* :cube-count (any ", ")))
      ,|(table/to-struct (merge ;$&)))
    :main (/ 
      (* :game-id (some (* :handful (any "; "))))
      ,|{:id $0 :handfuls $&})}))

(defn main [&]
  (with [f (file/open "day2_test.txt")]
    (def games (map |(first (peg/match game-grammar $)) (file/lines f)))
    # (pp games)
    (def pt1-maximums {:red 12 :green 13 :blue 14})
    (def pt1 (= 0 (length (filter
      ))

    (filter )
    # (map |(print ($ :id) ($ :games)) games)))
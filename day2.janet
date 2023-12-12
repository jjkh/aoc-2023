(def game-grammar
    ~{:num (number (some :d))
      :color (+ (/ "blue" :blue) (/ "green" :green) (/ "red" :red))
      :game (some (group (* :num " " :color (any (+ ", " "; ")))))
      :main (* "Game " :num ": " (some (group :game)))})

(defn main [&]
  (with [f (file/open "day2.txt")]
    (def lines (map string/trimr (file/lines f)))
    (def pt1 
      (map |(pp (peg/match game-grammar $)) lines))
))

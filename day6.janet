# This document describes three races:

#     The first race lasts 7 milliseconds. The record distance in this race is 9 millimeters.
#     The second race lasts 15 milliseconds. The record distance in this race is 40 millimeters.
#     The third race lasts 30 milliseconds. The record distance in this race is 200 millimeters.

# Your toy boat has a starting speed of zero millimeters per millisecond. For each whole millisecond you spend at the beginning of the race holding down the button, the boat's speed increases by one millimeter per millisecond.

# So, because the first race lasts 7 milliseconds, you only have a few options:

#     Don't hold the button at all (that is, hold it for 0 milliseconds) at the start of the race. The boat won't move; it will have traveled 0 millimeters by the end of the race.
#     Hold the button for 1 millisecond at the start of the race. Then, the boat will travel at a speed of 1 millimeter per millisecond for 6 milliseconds, reaching a total distance traveled of 6 millimeters.
#     Hold the button for 2 milliseconds, giving the boat a speed of 2 millimeters per millisecond. It will then get 5 milliseconds to move, reaching a total distance of 10 millimeters.
#     Hold the button for 3 milliseconds. After its remaining 4 milliseconds of travel time, the boat will have gone 12 millimeters.
#     Hold the button for 4 milliseconds. After its remaining 3 milliseconds of travel time, the boat will have gone 12 millimeters.
#     Hold the button for 5 milliseconds, causing the boat to travel a total of 10 millimeters.
#     Hold the button for 6 milliseconds, causing the boat to travel a total of 6 millimeters.
#     Hold the button for 7 milliseconds. That's the entire duration of the race. You never let go of the button. The boat can't move until you let go of the button. Please make sure you let go of the button so the boat gets to move. 0 millimeters.

# Since the current record for this race is 9 millimeters, there are actually 4 different ways you could win: you could hold the button for 2, 3, 4, or 5 milliseconds at the start of the race.

# In the second race, you could hold the button for at least 4 milliseconds and at most 11 milliseconds and beat the record, a total of 8 different ways to win.
# In the third race, you could hold the button for at least 11 milliseconds and no more than 19 milliseconds and still beat the record, a total of 9 ways you could win.

# To see how much margin of error you have, determine the number of ways you can beat the record in each race; in this example, if you multiply these values together, you get 288 (4 * 8 * 9).

# Determine the number of ways you could beat the record in each race. What do you get if you multiply these numbers together?

(def racecard-grammar-pt1 (peg/compile
  ~{:times (* "Time:" (some (* :s+ (number :d+))))
    :dists (* "Distance:" (some (* :s+ (number :d+))))
    :main (* (group :times) :s+ (group :dists))}))

(def racecard-grammar-pt2 (peg/compile
  ~{:times (* "Time:" (% (some (* :s+ (<- :d+)))))
    :dists (* "Distance:" (% (some (* :s+ (<- :d+)))))
    :main (* :times :s+ :dists)}))

(defn main [&]
  (def contents (slurp "day6.txt"))
  (def races-pt1
    (map 
      |{:time ($ 0) :dist ($ 1)}
      (partition 2 (interleave ;(peg/match racecard-grammar-pt1 contents)))))
  
  (def racecard-pt2
    (peg/match racecard-grammar-pt2 contents))
  (def race-pt2
    {:time (scan-number (racecard-pt2 0))
     :dist (scan-number (racecard-pt2 1))})
  
  (defn win-count [race]
    (last 
      (seq [time :range [1 (race :time)]
            :let [dist (* time (- (race :time) time))]
            :until (> dist (race :dist))]
        (- (race :time) (* time 2) 1))))

  (def pt1 
    (product (map win-count races-pt1)))
  (print "Part 1: " pt1)

  (def pt2 
    (win-count race-pt2))
  (print "Part 2: " pt2))
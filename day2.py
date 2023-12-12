from enum import Enum
import functools
from operator import mul
from typing import DefaultDict, Optional, TypeVar
from unittest import skip

class Color(Enum):
    RED = 'red'
    GREEN = 'green'
    BLUE = 'blue'

class Parser:
    curr_pos = 0
    line: str
    line_length: int

    def __init__(self, line: str):
        self.line = line
        self.line_length = len(line)
    
    def peek(self) -> Optional[str]:
        if self.curr_pos >= self.line_length:
            return None
        return self.line[self.curr_pos]
    
    def consume(self) -> Optional[str]:
        if self.curr_pos >= self.line_length:
            return None
        self.curr_pos += 1
        return self.line[self.curr_pos-1]
    
    def consume_whitespace(self):
        while self.peek() == ' ':
            self.consume()

    def consume_string(self, string: str) -> bool:
        if self.line[self.curr_pos:].startswith(string):
            self.curr_pos += len(string)
            return True
        return False

    def consume_int(self) -> Optional[int]:
        num: Optional[str] = None
        while c := self.peek():
            if c >= '0' and c <= '9':
                num = c if num is None else num + c 
            else:
                break
            self.consume()

        return None if num is None else int(num)

class GameParser(Parser):
    def consume_color(self) -> Optional[Color]:
        for c in Color:
            if self.consume_string(c.value):
                return c
        return None


T = TypeVar('T')
def not_none(obj: Optional[T]) -> T:
    assert obj is not None
    return obj

def parse_line(line) -> tuple[int, dict[Color, Optional[int]]]:
    maximums = {c: None for c in Color}
    p = GameParser(line)
    not_none(p.consume_string('Game '))
    game_id = not_none(p.consume_int())
    not_none(p.consume_string(': '))

    while True:
        count = not_none(p.consume_int())
        p.consume_whitespace()
        color = not_none(p.consume_color())
        if maximums[color] is None or count > maximums[color]:
            maximums[color] = count
        if p.consume_string(',') or p.consume_string(';'):
            p.consume_whitespace()
            continue
        break

    return game_id, maximums

def day2(file, debug = False) -> tuple[int, int]:
    part1_minimums = {Color.RED: 12, Color.GREEN: 13, Color.BLUE: 14}
    part1_game_count = 0

    part2_power = 0

    
    for line in file:
        game_id, game_minimums = parse_line(line)
        if debug:
            print(line.strip(), game_minimums)
        
        for color, count in game_minimums.items():
            if count is not None and count > part1_minimums[color]:
                break
        else:
            part1_game_count += game_id

        part2_power += functools.reduce(lambda x, y: x*y, (x for x in game_minimums.values() if x is not None))
    
    return part1_game_count, part2_power

if __name__ == '__main__':
    with open('day2.txt', 'r') as file:
        part1, part2 = day2(file, True)
        print("Part 1:", part1)
        print("Part 2:", part2)


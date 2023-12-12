from typing import ClassVar
from dataclasses import dataclass
from timeit import timeit

@dataclass
class Digit:
	num: int

@dataclass
class Word:
	valid_words: ClassVar[dict[str, int]] = {
		'one': 1, 'two': 2, 'three': 3, 
		'four': 4, 'five': 5, 'six': 6, 
		'seven': 7, 'eight': 8, 'nine': 9
	}
	num: int


def parse_line(line: str) -> list[Digit|Word]:
	nums: list[Digit|Word] = []
	cur_pos = 0
	line_length = len(line)

	def peek_word() -> Word|None:
		substr = line[cur_pos:]
		for word, num in Word.valid_words.items():
			if substr.startswith(word):
				return Word(num)
		return None

	def peek_digit() -> Digit|None:
		c = line[cur_pos]
		if c > '0' and c <= '9':
			return Digit(int(c))
		return None

	while cur_pos < line_length:
		if num := peek_digit() or peek_word():
			nums.append(num)
		cur_pos += 1
	return nums

def day1(file, debug = False) -> tuple[int, int]:
	part1_total = 0
	part2_total = 0
	for line in file:
		part2_nums = parse_line(line)
		part2_total += part2_nums[0].num*10 + part2_nums[-1].num
		if debug:
			print(line.strip(), part2_nums)

		part1_nums = [x.num for x in part2_nums if isinstance(x, Digit)]
		part1_total += part1_nums[0]*10 + part1_nums[-1]
	
	return part1_total, part2_total

if __name__ == '__main__':
	with open('day1.txt', 'r') as file:
		part1, part2 = day1(file, False)
		print("Part 1:", part1)
		print("Part 2:", part2)


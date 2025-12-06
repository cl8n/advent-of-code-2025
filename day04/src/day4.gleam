import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import puzzle

pub fn main() -> Nil {
  let lines =
    puzzle.download_and_cache("https://adventofcode.com/2025/day/4/input")
    |> string.trim()
    |> string.split("\n")

  io.println("Part 1")
  part1(lines)
  io.println("Part 2")
  part2(lines)
}

fn part1(lines: List(String)) -> Nil {
  let roll_positions = get_roll_positions(lines)

  set.fold(roll_positions, 0, fn(acc, position) {
    case count_adjacent_rolls(roll_positions, position) < 4 {
      True -> acc + 1
      False -> acc
    }
  })
  |> int.to_string
  |> io.println
}

fn part2(lines: List(String)) -> Nil {
  let roll_positions = get_roll_positions(lines)
  let cleaned_roll_positions = remove_all_possible_rolls(roll_positions)

  set.size(roll_positions) - set.size(cleaned_roll_positions)
  |> int.to_string
  |> io.println
}

fn remove_all_possible_rolls(
  roll_positions: set.Set(#(Int, Int)),
) -> set.Set(#(Int, Int)) {
  let next_roll_positions =
    set.fold(roll_positions, set.new(), fn(acc, position) {
      case count_adjacent_rolls(roll_positions, position) < 4 {
        True -> acc
        False -> set.insert(acc, position)
      }
    })

  case set.size(roll_positions) == set.size(next_roll_positions) {
    True -> next_roll_positions
    False -> remove_all_possible_rolls(next_roll_positions)
  }
}

fn get_roll_positions(lines: List(String)) -> set.Set(#(Int, Int)) {
  list.index_fold(lines, set.new(), fn(acc, line, line_index) {
    string.to_graphemes(line)
    |> list.index_fold(set.new(), fn(acc, char, char_index) {
      case char {
        "@" -> acc |> set.insert(#(line_index, char_index))
        "." -> acc
        _ -> panic as "Unexpected input"
      }
    })
    |> set.union(acc)
  })
}

fn count_adjacent_rolls(
  roll_positions: set.Set(#(Int, Int)),
  position: #(Int, Int),
) -> Int {
  let #(row, col) = position

  list.range(row - 1, row + 1)
  |> list.fold(0, fn(acc, check_row) {
    let count =
      list.range(col - 1, col + 1)
      |> list.fold(0, fn(acc, check_col) {
        case position == #(check_row, check_col) {
          True -> acc
          False ->
            case set.contains(roll_positions, #(check_row, check_col)) {
              True -> acc + 1
              False -> acc
            }
        }
      })
    acc + count
  })
}

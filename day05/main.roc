app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import cli.Arg exposing [Arg]
import cli.Stdout
import Puzzle

main! : List Arg => Result {} _
main! = |_|
    input = get_input!({})?

    Stdout.line!("Part 1:")?
    Stdout.line!(part1(input))?
    Stdout.line!("Part 2:")?
    Stdout.line!(part2(input))

Input := {
    fresh_ranges : List (U64, U64),
    available : List U64,
}

get_input! : {} => Result Input _
get_input! = |_|
    { before: fresh_lines, after: available_lines } =
        Puzzle.download_and_cache!("https://adventofcode.com/2025/day/5/input")?
        |> Str.trim()
        |> Str.split_on("\n")
        |> List.split_first("")?

    Ok(
        @Input {
            fresh_ranges: fresh_lines
            |> List.map_try(
                |line|
                    { before, after } = Str.split_first(line, "-")?

                    when (Str.to_u64(before), Str.to_u64(after)) is
                        (Ok(start), Ok(end)) -> Ok((start, end))
                        _ -> Err(RangeParseError),
            )?,
            available: available_lines |> List.map_try(Str.to_u64)?,
        },
    )

part1 : Input -> Str
part1 = |@Input { fresh_ranges, available }|
    available
    |> List.count_if(
        |id|
            fresh_ranges
            |> List.any(|(start, end)| id >= start and id <= end),
    )
    |> Num.to_str()

part2 : Input -> Str
part2 = |@Input { fresh_ranges }|
    fresh_ranges
    |> List.sort_with(
        |(start1, end1), (start2, end2)|
            when Num.compare(start1, start2) is
                EQ -> Num.compare(end1, end2)
                order -> order,
    )
    |> List.walk(
        [],
        |acc, (start, end)|
            when acc is
                [] -> [(start, end)]
                [.. as head, (last_start, last_end)] if last_end >= start ->
                    List.append(head, (last_start, Num.max(last_end, end)))

                _ -> List.append(acc, (start, end)),
    )
    |> List.walk(0, |acc, (start, end)| acc + (end - start + 1))
    |> Num.to_str()

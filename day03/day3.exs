:inets.start()
:ssl.start()

defmodule Puzzle do
  @spec download_and_cache(String.t()) :: binary()
  def download_and_cache(url) do
    filename = Base.encode16(url)

    case File.read(filename) do
      {:ok, data} ->
        data

      {:error, :enoent} ->
        puzzle = download(url)
        File.write!(filename, puzzle)
        puzzle

      {:error, reason} ->
        raise(:file.format_error(reason))
    end
  end

  @spec download(String.t()) :: binary()
  defp download(url) do
    IO.puts(:stderr, "Downloading #{url}")

    cookie = String.trim(File.read!("session"))

    case :httpc.request(
           :get,
           {String.to_charlist(url),
            [
              {~c"Cookie", cookie}
            ]},
           [],
           [
             {:body_format, :binary},
             {:full_result, false}
           ]
         ) do
      {:ok, {200, body}} ->
        body

      {:ok, result} ->
        IO.puts(:stderr, inspect(result))
        raise("Unexpected response")

      {:error, reason} ->
        raise(reason)
    end
  end
end

defmodule Day3 do
  @spec part1 :: :ok
  def part1 do
    for bank <- get_input() do
      batteries =
        bank
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)

      max_index_1 =
        batteries
        |> Enum.slice(0..-2//1)
        |> index_of_first_max(0)

      max_index_2 =
        batteries
        |> Enum.slice((max_index_1 + 1)..-1//1)
        |> index_of_first_max(max_index_1 + 1)

      Enum.at(batteries, max_index_1) * 10 + Enum.at(batteries, max_index_2)
    end
    |> Enum.sum()
    |> IO.puts()
  end

  @spec part2 :: :ok
  def part2 do
    for bank <- get_input() do
      batteries =
        bank
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)

      {jolts, _} =
        Enum.reduce(12..1//-1, {0, 0}, fn remaining, {jolts, next_index} ->
          max_index =
            batteries
            |> Enum.slice(next_index..-remaining//1)
            |> index_of_first_max(next_index)

          {
            jolts + Enum.at(batteries, max_index) * Integer.pow(10, remaining - 1),
            max_index + 1
          }
        end)

      jolts
    end
    |> Enum.sum()
    |> IO.puts()
  end

  @spec index_of_first_max([integer()], non_neg_integer(), integer(), non_neg_integer()) ::
          non_neg_integer()
  defp index_of_first_max(_, _, _ \\ 0, _ \\ 0)
  defp index_of_first_max([], _, _, max_index), do: max_index

  defp index_of_first_max([head | tail], index, max, _) when head > max,
    do: index_of_first_max(tail, index + 1, head, index)

  defp index_of_first_max([_ | tail], index, max, max_index),
    do: index_of_first_max(tail, index + 1, max, max_index)

  @spec get_input :: [String.t()]
  defp get_input do
    Puzzle.download_and_cache("https://adventofcode.com/2025/day/3/input")
    |> to_string()
    |> String.trim()
    |> String.split("\n")
  end
end

IO.puts("Part 1:")
Day3.part1()
IO.puts("\nPart 2:")
Day3.part2()

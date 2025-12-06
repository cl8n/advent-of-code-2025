import gleam/http/request
import gleam/httpc
import gleam/result
import gleam/string
import simplifile

pub fn download_and_cache(url: String) -> String {
  case simplifile.read("input") {
    Ok(input) -> input
    Error(_) -> {
      let input = download(url)
      assert simplifile.write("input", input) == Ok(Nil)
      input
    }
  }
}

fn download(url: String) -> String {
  let assert Ok(cookie) =
    simplifile.read("../session") |> result.map(string.trim)

  let assert Ok(req) =
    request.to(url) |> result.map(request.set_header(_, "cookie", cookie))
  let assert Ok(res) = httpc.send(req)

  assert res.status == 200

  res.body
}

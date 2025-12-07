module [download_and_cache!]

import cli.File
import cli.Http

download_and_cache! : Str => Result Str _
download_and_cache! = |url|
    when File.read_utf8!("input") is
        Ok(input) -> Ok(input)
        Err(_) ->
            input = download!(url)?
            File.write_utf8!(input, "input")?
            Ok(input)

download! : Str => Result Str _
download! = |url|
    cookie = File.read_utf8!("../session")? |> Str.trim()

    { status, body } = Http.send!(
        { Http.default_request &
            uri: url,
            headers: [Http.header(("Cookie", cookie))],
        },
    )?

    if status == 200 then
        Str.from_utf8(body)
    else
        Err(PuzzleDownloadError)

# ExLinkHeader

Parse HTTP link headers in Elixir.

# Usage

```elixir
ExLinkHeader.parse!("<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\", <https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"last\", <https://api.github.com/user/simonrand/repos?page=1&per_page=100>; rel=\"first\"")
#=> %{"first" => %{page: "1", per_page: "100", rel: "first", url: "https://api.github.com/user/simonrand/repos?page=1&per_page=100"}, "last" => %{page: "3", per_page: "100", rel: "last", url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100"}, "next" => %{page: "2", per_page: "100", rel: "next", url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2"} }

ExLinkHeader.parse!("")
#=> ** (ExLinkHeader.ParseError) Parse error: no valid links to parse
```

## Note a change in v0.0.4

Links with no `page` or `per_page` param previously returned `nil` by default for both these params, even if they did not exist - this is now no longer the case, `page` and `per_page` are now treated like any other query params. To return `nil` for these values you can supply defaults for any param when calling `parse` to ensure default values are returned, for example:

```
ExLinkHeader.parse!("<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\"", %{page: nil})
#=> %{"next" => %{
        url: "https://api.github.com/user/simonrand/repos?per_page=100",
        page: nil,
        per_page: "100",
        rel: "next"
      }
    }
```

## Code Status

[![Build Status](https://travis-ci.org/simonrand/ex_link_header.svg?branch=master)](https://travis-ci.org/simonrand/ex_link_header)

## Installation

The package can be installed as:

  1. Add ex_link_header to your list of dependencies in `mix.exs`:

        def deps do
          [{:ex_link_header, "~> 0.0.4"}]
        end

  2. Ensure ex_link_header is started before your application:

        def application do
          [applications: [:ex_link_header]]
        end

## License

Released under the Apache 2 License.

See [LICENSE](LICENSE) for more information.

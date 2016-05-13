defmodule ExLinkHeaderBuildTest do
  use ExUnit.Case
  doctest ExLinkHeader

  alias ExLinkHeader.BuildError
  require ExLinkHeader


  test "build raises if wrong query params are passed" do
    rel = "next"
    url = "http://www.example.com"

    link = %ExLinkHeader{url: url,
      relation: rel,
      q_params: [q: 'elixir']
      }
    assert_raise BuildError, fn -> ExLinkHeader.build(link) end
  end

  test "build a simple link" do
    rel = "next"
    url = "http://www.example.com"

    link = %ExLinkHeader{url: url,
      relation: rel
      }
    link_h = ExLinkHeader.build(link) 

    assert link_h == "<" <> url <> ">; rel=\"" <> rel <> "\""

    assert ExLinkHeader.parse!(link_h) ==
      %{rel => %{
          url: url,
          rel: rel
        }
      }
  end

  test "build a link with query params" do
    rel = "next"
    url = "http://www.example.com"

    link = %ExLinkHeader{url: url,
      relation: rel,
      q_params: [q: "elixir", page: 5]
      }
    link_h = ExLinkHeader.build(link) 

    assert link_h == "<" <> url <> "?q=elixir&page=5>; rel=\"" <> rel <> "\""

    assert ExLinkHeader.parse!(link_h) ==
      %{rel => %{
          url: url <> "?q=elixir&page=5",
          rel: rel,
          q: "elixir",
          page: "5"
        }
      }
  end

  test "build some simple links" do
    rel_a = "next"
    url_a = "http://www.example.com"

    link_a = %ExLinkHeader{url: url_a,
      relation: rel_a
      }

    rel_b = "prev"
    url_b = "http://www.example.com"
    link_b = %ExLinkHeader{url: url_b,
      relation: rel_b
      }

    link_h = ExLinkHeader.build([link_a, link_b])
    assert link_h == "<" <> url_a <> ">; rel=\"" <> rel_a <> "\", " <>
      "<" <> url_b <> ">; rel=\"" <> rel_b <> "\""

    assert ExLinkHeader.parse!(link_h) ==
      %{rel_a => %{
          url: url_a,
          rel: rel_a
        },
        rel_b => %{
          url: url_b,
          rel: rel_b
        }
      }
  end

end

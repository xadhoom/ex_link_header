defmodule ExLinkHeaderTest do
  use ExUnit.Case
  doctest ExLinkHeader

  alias ExLinkHeader.ParseError
  require ExLinkHeader

  test "parsing a header with next and last links, different order url params and different spacing between links" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"last\"," <>
      "<https://api.github.com/user/simonrand/repos?page=1&per_page=100>; rel=\"first\""

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "last"
        },
        "first" => %{
          url: "https://api.github.com/user/simonrand/repos?page=1&per_page=100",
          page: "1",
          per_page: "100",
          rel: "first"
        }
      }
  end

  test "parsing a header with extra params and different param spacing" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next\";ler=\"page\""

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next",
          ler: "page"
        }
      }
  end

  test "parsing a header with multiple rel values and spaces" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=\"next last\"; ler=\"page\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=\"prev first \""

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next",
          ler: "page"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "last",
          ler: "page"
        },
        "prev" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "prev"
        },
        "first" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "first"
        }
      }
  end

  test "parsing a header with next and last and no space between links and no default values" do
    link_header =
      "<https://api.github.com/user/simonrand/repos>; rel=\"next\"," <>
      "<https://api.github.com/user/simonrand/repos>; rel=\"last\""

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos",
          rel: "last"
        }
      }
  end

  test "parsing a header with unquoted relationships" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=next, " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; rel=last"

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3&per_page=100",
          page: "3",
          per_page: "100",
          rel: "last"
        }
      }
  end

  test "parsing a header with next and last links and only some url params" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\", " <>
      "<https://api.github.com/user/simonrand/repos?page=3>; rel=\"last\""

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100",
          per_page: "100",
          rel: "next"
        },
        "last" => %{
          url: "https://api.github.com/user/simonrand/repos?page=3",
          page: "3",
          rel: "last"
        }
      }
  end


  test "parsing a header with an invalid url and a default for value page" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100>; rel=\"next\", " <>
      "<https//api.github.com/user/simonrand/repos?page=3>; rel=\"last\""

    assert ExLinkHeader.parse!(link_header, %{page: nil}) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100",
          page: nil,
          per_page: "100",
          rel: "next"
        }
      }
  end

  test "parsing a header including a link without a relationship param" do
    link_header =
      "<https://api.github.com/user/simonrand/repos?per_page=100&page=2>; rel=next, " <>
      "<https://api.github.com/user/simonrand/repos?page=3&per_page=100>; ler=last"

    assert ExLinkHeader.parse!(link_header) ==
      %{"next" => %{
          url: "https://api.github.com/user/simonrand/repos?per_page=100&page=2",
          page: "2",
          per_page: "100",
          rel: "next"
        }
      }
  end

  test "parsing a header with a comma in a link and default values" do
    link_header =
      "<https://api.github.com/search/repositories?q=elixir,ruby&sort=stars&order=desc>; rel=\"last\""

    assert ExLinkHeader.parse!(link_header, %{page: nil, per_page: nil}) ==
      %{"last" => %{
          url: "https://api.github.com/search/repositories?q=elixir,ruby&sort=stars&order=desc",
          page: nil,
          per_page: nil,
          rel: "last",
          q: "elixir,ruby",
          sort: "stars",
          order: "desc"
        }
      }
  end

  test "parsing a header with arbitrary params and no defaults" do
    link_header =
      "<https://api.example.com/?q=elixir&sort=stars&order=desc>; rel=\"last\""

    assert ExLinkHeader.parse!(link_header) ==
      %{"last" => %{
          url: "https://api.example.com/?q=elixir&sort=stars&order=desc",
          q: "elixir",
          sort: "stars",
          order: "desc",
          rel: "last"
        }
      }

  end

  test "parsing a header with no path, arbitrary params and no defaults" do
    link_header =
      "<https://api.example.com?q=elixir&sort=stars&order=desc>; rel=\"last\""

    assert ExLinkHeader.parse!(link_header) ==
      %{"last" => %{
          url: "https://api.example.com?q=elixir&sort=stars&order=desc",
          q: "elixir",
          sort: "stars",
          order: "desc",
          rel: "last"
        }
      }

  end

  test "parsing an empty or invalid link header raises" do
    assert_raise ParseError, fn -> ExLinkHeader.parse!("") end
    assert_raise ParseError, fn -> ExLinkHeader.parse!("nonsense") end
  end

  test "create a simple link" do
    rel = "next"
    url = "http://www.example.com"

    link = %ExLinkHeader{url: url,
      relation: rel
      }
    link_h = ExLinkHeader.create(link) 

    assert link_h == "<" <> url <> ">; rel=\"" <> rel <> "\""

    assert ExLinkHeader.parse!(link_h) ==
      %{rel => %{
          url: url,
          rel: rel
        }
      }
  end

  test "create some simple links" do
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

    link_h = ExLinkHeader.create([link_a, link_b])
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

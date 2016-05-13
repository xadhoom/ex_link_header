defmodule ExLinkHeader.Builder do

  alias ExLinkHeader.BuildError

  @moduledoc """
  HTTP link header builder
  """

  def build(%ExLinkHeader{} = h) do
    q = Enum.map_join(Keyword.keys(h.q_params), "&", fn(key) ->
      # TODO: sanitize me
      val = case Keyword.get(h.q_params, key) do
        v when is_integer(v) -> Integer.to_string(v)  
        v when is_atom(v) -> Atom.to_string(v)
        v when is_binary(v) -> v
        _ -> raise BuildError, "Invalid query param value"
      end
      Atom.to_string(key) <> "=" <> val
    end)

    uri = case q do
      "" -> h.url
      v when is_binary(v) -> h.url <> "?" <> v
      _ -> h.url
    end
    "<" <> uri <> ">; rel=\"" <> h.relation <> "\""
  end

  def build(headers) when is_list headers do
    Enum.map_join(headers, ", ", fn(h) -> __MODULE__.build(h) end)
  end

end

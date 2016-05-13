defmodule ExLinkHeader do

  @moduledoc """
  HTTP link header parser and builder
  """

  defstruct url: :nil,
    relation: :nil,
    q_params: []
    
  defmodule ParseError do
    @moduledoc """
    HTTP link header parse error
    """

    defexception [:message]

    def exception(msg), do: %__MODULE__{message: msg}
  end

  defmodule BuildError do
    @moduledoc """
    HTTP link header build error
    """

    defexception [:message]

    def exception(msg), do: %__MODULE__{message: msg}
  end

  def parse(header, defaults \\ %{}) do
    ExLinkHeader.Parser.parse(header, defaults)
  end

  def parse!(header, defaults \\ %{}) do
    ExLinkHeader.Parser.parse!(header, defaults)
  end

  def build(h) do
    ExLinkHeader.Builder.build(h)
  end

end

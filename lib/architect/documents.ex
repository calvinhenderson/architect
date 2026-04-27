defmodule Architect.Documents do
  @moduledoc """
  An API for interacting with YAML documents.
  """

  @type parsing_error() :: %{error: binary(), line: number(), character: number()}
  @type decode_error() ::
          {:error, :decode_yaml, [parsing_error()]}

  @doc """
  Loads a yaml document to a list of maps.

  ## Example

      iex> document = \"""
      > example: true
      > \"""
      iex> load_yaml(document)
      [%{"example" => true}]
  """
  @spec load_yaml(binary(), keyword()) :: [map()] | decode_error()
  def load_yaml(contents, opts \\ []) do
    try do
      :yamerl.decode(contents, opts)
      |> do_decode_documents()
    catch
      {:yamerl_exception, errors} ->
        errors =
          errors
          |> Enum.map(fn {:yamerl_parsing_error, :error, msg, line, character, _, _, _} ->
            %{error: to_string(msg), line: line, character: character}
          end)

        {:error, :decode_yaml, errors}
    end
  end

  defguardp is_json_term(term)
            when is_boolean(term) or is_binary(term) or is_number(term) or is_map(term) or
                   is_list(term)

  defguardp is_charlist(term) when is_list(term)

  defp do_decode_documents(documents) when is_list(documents) do
    Enum.map(documents, fn
      [head | _] = doc when is_list(head) ->
        doc
        |> do_decode_documents()

      [head | _] = doc when is_tuple(head) ->
        doc
        |> do_decode_document()
        |> Enum.into(%{})

      head when is_json_term(head) ->
        do_decode_yaml(head)

      :null ->
        :null
    end)
  end

  defp do_decode_document(keys) when is_list(keys) do
    Enum.map(keys, &do_decode_yaml/1)
  end

  # Handle simple terms
  defp do_decode_yaml(term) when is_json_term(term) do
    case term do
      [head | _] when is_list(head) -> Enum.map(term, &do_decode_yaml/1)
      [head | _] when is_tuple(head) -> Enum.map(term, &do_decode_yaml/1) |> Enum.into(%{})
      [_ | _] -> maybe_decode_charlist(term)
      _ -> term
    end
  end

  # Handle map keys
  defp do_decode_yaml({:null, val}), do: {:null, do_decode_yaml(val)}

  defp do_decode_yaml({key, val}) when is_charlist(key),
    do: {to_string(key), do_decode_yaml(val)}

  defp maybe_decode_charlist(term) do
    if to_string(term) |> String.valid?(), do: to_string(term), else: term
  end
end

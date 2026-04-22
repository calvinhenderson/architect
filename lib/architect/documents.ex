defmodule Architect.Documents do
  def load_yaml(contents, opts \\ []) do
    :yamerl.decode(contents, opts)
    |> do_decode_documents()
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

      ignored when ignored == :null or ignored == [] ->
        []
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
  defp do_decode_yaml({key, val}) when is_charlist(key),
    do: {to_string(key), do_decode_yaml(val)}

  defp maybe_decode_charlist(term) do
    if to_string(term) |> String.valid?(), do: to_string(term), else: term
  end
end

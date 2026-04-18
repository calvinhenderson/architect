defmodule Architect.Schemas.Embedded do
  @moduledoc "Resolver for embedded schemas"

  paths = Path.wildcard("schemas/**/*.json")
  @schemas_hash :erlang.md5(paths)
  @embedded_schema_dir :code.priv_dir(:architect) |> Path.join("schemas")

  for p <- paths do
    @external_resource p
  end

  # Resolve internal schema
  @spec resolve(binary(), binary()) ::
          map() | {:error, :resolve_schema, term()}
  def resolve(ref, schema_dir \\ @embedded_schema_dir)
      when is_binary(ref) and is_binary(schema_dir) do
    with {:ok, contents} <- load_document(ref, schema_dir),
         {:ok, document} <-
           decode_document(contents) do
      document
    else
      {:error, reason, arg} ->
        {:error, reason, arg}
    end
  end

  defp load_document(ref, schema_dir) do
    ref_parts = String.split(ref <> ".json", "/")
    ref_path = Path.join([schema_dir | ref_parts])

    case File.read(ref_path) do
      {:ok, contents} -> {:ok, contents}
      {:error, reason} -> {:error, :resolve_schema, reason}
    end
  end

  defp decode_document(data) when is_binary(data) do
    case JSON.decode(data) do
      {:ok, document} -> {:ok, document}
      {:error, reason} -> {:error, :decode_schema, reason}
    end
  end

  def __mix_recompile__?() do
    Path.wildcard("schemas/**/*.json") |> :erlang.md5() != @schemas_hash
  end
end

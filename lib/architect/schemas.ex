defmodule Architect.Schemas do
  @moduledoc """
  Provides an API for interacting with application JSON Schemas.
  """

  alias Architect.Schemas.Resolver

  @type schema :: map() | binary()

  @spec resolve_schema!(schema()) :: term()
  def resolve_schema!(schema) do
    {:ok, resolved} = do_resolve_schema(schema)
    resolved
  end

  @spec resolve_schema(schema()) :: {:ok, term()} | {:error, :resolve_schema, term()}
  def resolve_schema(schema) do
    case do_resolve_schema(schema) do
      {:ok, resolved} -> {:ok, resolved}
      error -> error
    end
  end

  defp do_resolve_schema(schema) do
    case Resolver.resolve(schema) do
      resolved when is_map(resolved) -> {:ok, resolved}
      resolve_error -> resolve_error
    end
  end

  @spec validate_data(schema(), term()) :: {:ok, term()} | {:error, :validate_schema_data, term()}
  def validate_data(schema, data) do
    with {:ok, resolved} <- resolve_schema(schema),
         {:ok, validated} <- do_validate_data(resolved, data) do
      {:ok, validated}
    else
      error -> error
    end
  end

  defp do_validate_data(schema, data) do
    case ExJsonSchema.Validator.validate(schema, data) do
      :ok -> {:ok, data}
      {:error, errors} -> {:error, :validate_schema_data, errors}
    end
  end
end

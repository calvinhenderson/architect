defmodule Architect.Schemas.Resolver do
  alias Architect.Schemas.Embedded

  @spec resolve(binary()) :: struct() | {:error, :resolve_schema, term()}
  def resolve(_ref)

  def resolve(schema) when is_map(schema), do: schema

  # Resolve plugin schemas
  def resolve("schemas/plugins/" <> _ = _ref), do: raise("Not implemented")

  def resolve("schemas/" <> ref), do: Embedded.resolve(ref)

  # Resolve remote schemas
  def resolve(_ref), do: raise("Not implemented")
end

defmodule Architect.SchemasTest do
  use Architect.DataCase

  import Architect.Schemas

  describe "resolve_schema!/1" do
    test "resolves a valid schema" do
      assert "schemas/blueprint"
             |> resolve_schema!()
             |> is_map()
    end

    test "raises for invalid schemas" do
      assert_raise RuntimeError, fn ->
        resolve_schema!("invalid schema")
      end
    end
  end

  describe "resolve_schema/1" do
    test "resolves an internal schema" do
      {:ok, schema} = resolve_schema("schemas/blueprint")
      assert is_map(schema)
    end

    test "resolves a plugin schema"
    test "resolves a remote schema"
    test "returns validation errors"
  end

  describe "validate_data/2" do
    test "validates data against the schema"
    test "returns validation errors"
  end
end

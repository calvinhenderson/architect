defmodule Architect.SchemasTest do
  use Architect.DataCase

  import Architect.Schemas

  @valid_schema %{
    "$id" => "schemas/test",
    "$schema" => "http://json-schema.org/draft-07/schema#",
    "type" => "object",
    "additionalProperties" => false,
    "properties" => %{
      "valid" => %{
        "type" => "boolean"
      }
    },
    "required" => ["valid"]
  }
  @valid_params %{"valid" => true}

  @invalid_schema %{"properties" => ["invalid"]}
  @invalid_params %{}

  describe "resolve_schema!/1" do
    test "resolves a valid schema" do
      assert @valid_schema
             |> resolve_schema!()
             |> is_map()
    end

    test "raises for invalid schemas" do
      assert_raise RuntimeError, fn ->
        resolve_schema!(@invalid_schema)
      end
    end
  end

  describe "resolve_schema/1" do
    test "resolves an internal schema" do
      {:ok, schema} = resolve_schema(@valid_schema)
      assert is_map(schema)
    end

    test "resolves a plugin schema"
    test "resolves a remote schema"

    test "returns invalid schema error" do
      assert {:error, :invalid_schema, _schema} =
               resolve_schema(@invalid_schema)
    end
  end

  describe "validate_data/2" do
    test "validates data against the schema" do
      data = @valid_params
      assert {:ok, ^data} = validate_data(@valid_schema, data)
    end

    test "returns validation errors" do
      assert {:error, :validate_schema_data, errors} =
               validate_data(@valid_schema, @invalid_params)

      assert {"Required property valid was not present.", "#"} in errors
    end

    test "returns schema errors" do
      assert {:error, :invalid_schema, _schema} = validate_data(@invalid_schema, @valid_params)
    end
  end
end

defmodule Architect.DocumentsTest do
  use Architect.DocumentsTestsCase

  describe "load_yaml/2" do
    test "returns errors for invalid documents" do
      invalid_document = """
      valid: true
      invalid
      """

      assert {:error, :decode_yaml, errors} = load_yaml(invalid_document)

      assert %{
               error: "Expected sequence entry or mapping implicit key not found",
               line: 2,
               character: 1
             } in errors
    end
  end

  describe "document tests" do
    generate_document_tests("test/architect/documents/*.yaml")
  end
end

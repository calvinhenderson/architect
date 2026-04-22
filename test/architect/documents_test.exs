defmodule Architect.DocumentsTest do
  use Architect.DocumentsTestsCase

  describe "blueprints" do
    generate_document_tests("test/architect/documents/blueprints.yaml")
  end
end

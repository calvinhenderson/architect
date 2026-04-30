defmodule Architect.DocumentsTestsCase do
  @moduledoc """
  Provides a test case for document tests.
  """

  defmacro generate_document_tests(search_path) do
    search_path
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(fn path ->
      document =
        path
        |> File.read!()
        |> Architect.Documents.load_yaml()
        |> List.first()

      {path, document}
      |> map_test_case()
    end)
  end

  defp map_test_case({_, %{"fail" => true, "name" => name, "yaml" => yaml}}) do
    quote do
      test unquote(name) do
        yaml = unquote(yaml)
        assert {:error, :decode_yaml, _errors} = Architect.Documents.load_yaml(yaml)
      end
    end
  end

  defp map_test_case({_, %{"name" => name, "yaml" => yaml, "json" => json}}) do
    quote do
      test unquote(name) do
        json = JSON.decode!(unquote(json))
        yaml = Architect.Documents.load_yaml(unquote(yaml))
        assert json == yaml
      end
    end
  end

  defp map_test_case({test_case, _}) do
    raise "Invalid test case format: #{test_case}"
  end

  defmacro __using__(_) do
    quote do
      use Architect.DataCase
      import unquote(__MODULE__)
      import Architect.Documents
    end
  end
end

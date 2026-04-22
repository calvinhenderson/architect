defmodule Architect.DocumentsTestsCase do
  defmacro generate_document_tests(search_path) do
    search_path
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(&File.read!/1)
    |> Enum.map(&Architect.Documents.load_yaml/1)
    |> Enum.map(&List.first/1)
    |> Enum.map(&Map.put_new(&1, "fail", false))
    |> Enum.map(fn
      %{"fail" => true} = test_case ->
        quote do
          test unquote(test_case["name"]) do
            yaml = unquote(test_case["yaml"])
            assert catch_throw(Architect.Documents.load_yaml(yaml))
          end
        end

      test_case ->
        name = test_case["name"]
        yaml = test_case["yaml"]
        json = test_case["json"]

        quote do
          test unquote(name) do
            json = JSON.decode!(unquote(json))
            yaml = Architect.Documents.load_yaml(unquote(yaml))
            assert json == yaml
          end
        end
    end)
  end

  defmacro __using__(_) do
    quote do
      use Architect.DataCase
      import unquote(__MODULE__)
      import Architect.Documents
    end
  end
end

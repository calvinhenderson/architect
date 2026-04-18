defmodule Architect.Blueprints.Blueprint do
  @moduledoc "A structured blueprint"

  @type t :: [
          id: binary(),
          description: binary(),
          namespace: binary(),
          env: map(),
          inputs: map(),
          outputs: map(),
          tasks: list(),
          triggers: map()
        ]

  defstruct [
    :id,
    :description,
    :namespace,
    :tasks,
    env: %{},
    inputs: %{},
    outputs: %{},
    triggers: %{}
  ]
end

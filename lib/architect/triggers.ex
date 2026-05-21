defmodule Architect.Triggers do
  @moduledoc """
  Provides an API for the outside world to spawn task runs.
  """

  def sync_task_triggers(task), do: nil
  def handle_webhook(webhook_path, payload), do: nil
  def evaluate_schedules, do: nil
end

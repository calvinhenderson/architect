defmodule Architect.TriggersTest do
  use Architect.DataCase

  describe "sync_task_triggers/1" do
    test "adds task triggers"
    test "removes orphaned triggers"
  end

  describe "handle_webhook/2" do
    test "queues runs for valid webhooks"
  end

  describe "evaluate_schedules/0" do
    test "queues run for valid schedules"
  end
end

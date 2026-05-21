defmodule Architect.ExecutionTest do
  use Architect.DataCase

  describe "enqueue_run/3" do
    test "adds new run to the queue"
  end

  describe "claim_run/1" do
    test "claims the next available run"
    test "updates status to running"
    test "updates heartbeat"
  end

  describe "update_run_heartbeat/1" do
    test "updates heartbeat"
  end

  describe "upsert_run_step/2" do
    test "inserts new steps"
    test "updates existing steps"
    test "step ids are unique"
  end

  describe "complete_run/2" do
    test "updates run status"
    test "sets completed_at"
  end

  describe "update_run/2" do
    test "updates run with valid params"
    test "returns changeset for invalid params"
  end

  describe "reap_stale_runs/1" do
    test "resets run status to pending"
    test "clears run worker metadata"
  end
end

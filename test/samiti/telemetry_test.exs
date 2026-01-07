defmodule Samiti.TelemetryTest do
  use ExUnit.Case, async: true

  setup context do
    on_exit(fn -> Samiti.put_tenant(nil) end)

    repo =
      cond do
        context[:postgres] -> Samiti.TestRepo.Postgres
        context[:mysql] -> Samiti.TestRepo.MySQL
        true -> nil
      end

    if repo do
      start_supervised!(repo)
      Ecto.Adapters.SQL.Sandbox.checkout(repo)
    end

    {:ok, repo: repo}
  end

  @tag :postgres
  test "emits [:samiti, :tenant, :create] event" do
    parent = self()
    handler_id = "telemetry-test"

    :telemetry.attach(
      handler_id,
      [:samiti, :tenant, :create],
      fn _name, _measurements, metadata, _config ->
        send(parent, {:event_captured, metadata.tenant})
      end,
      nil
    )

    # We can use a mock repo or a real one here
    Samiti.create(Samiti.TestRepo.Postgres, "telemetry_tenant")

    assert_receive {:event_captured, "telemetry_tenant"}

    :telemetry.detach(handler_id)
  end
end

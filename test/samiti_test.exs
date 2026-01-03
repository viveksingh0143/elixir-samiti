defmodule SamitiTest do
  use ExUnit.Case
  alias Samiti.TestRepo
  doctest Samiti

  setup do
    start_supervised!(TestRepo)
    :ok
  end

  setup do
    # Ensure the Repo is started
    {:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(TestRepo.config(), :temporary)

    # Start the repo if not already running
    case TestRepo.start_link() do
      {:ok, pid} -> {:ok, repo: pid}
      {:error, {:already_started, pid}} -> {:ok, repo: pid}
    end
  end

  test "creates and drops a postgres schema" do
    tenant_name = "test_tenant_#{System.unique_integer([:positive])}"

    assert :ok = Samiti.create(TestRepo, tenant_name)

    result =
      TestRepo.query!(
        "SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1",
        [tenant_name]
      )

    assert result.num_rows == 1

    assert :ok = Samiti.drop(TestRepo, tenant_name)

    result =
      TestRepo.query!(
        "SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1",
        [tenant_name]
      )

    assert result.num_rows == 0
  end
end

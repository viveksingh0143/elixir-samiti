defmodule Samiti do
  @moduledoc """
  Samiti provides functions to manage tenant isolation.

  It supports creating and dropping tenant containers (Postgres Schemas or MySQL Databases)
  and running migrations for specific tenants.
  """

  @tenant_key :samiti_prefix

  @doc "Sets the tenant prefix for the current process."
  def put_tenant(prefix), do: Process.put(@tenant_key, prefix)

  @doc "Gets the tenant prefix from the current process."
  def get_tenant, do: Process.get(@tenant_key)

  @doc """
  Runs a block of code without any tenant prefix.
  Useful for querying global tables from within a tenant request.
  """
  def scope_global(fun) do
    current = get_tenant()
    put_tenant(nil)
    try do: fun.(), after: put_tenant(current)
  end

  @doc """
  Creates a new tenant container.

  For Postgres, it creates a new Schema.
  For MySQL, it creates a new Database.
  """
  def create(repo, name) do
    execute_and_log(repo, "create", name, fn ->
      case adapter(repo) do
        Ecto.Adapters.Postgres ->
          repo.query!("CREATE SCHEMA \"#{name}\"")

        _ ->
          repo.query!("CREATE DATABASE `#{name}`")
          # Ecto.Adapters.MyXQL ->
          #   repo.query!("CREATE DATABASE `#{name}`")
      end

      :ok
    end)
  end

  @doc """
  Drops a tenant container.

  For Postgres, it drops the Schema.
  For MySQL, it drops the Database.
  """
  def drop(repo, name) do
    execute_and_log(repo, "drop", name, fn ->
      case adapter(repo) do
        Ecto.Adapters.Postgres ->
          repo.query!("DROP SCHEMA \"#{name}\" CASCADE")

        _ ->
          repo.query!("DROP DATABASE `#{name}`")
          # Ecto.Adapters.MyXQL ->
          #   repo.query!("DROP DATABASE `#{name}`")
      end

      :ok
    end)
  end

  @doc """
  Runs migrations for a specific tenant.
  """
  def migrate(repo, name, migration_path) do
    execute_and_log(repo, "migrate", name, fn ->
      Ecto.Migrator.run(repo, migration_path, :up,
        all: true,
        prefix: name,
        schema_migration_prefix: name
      )

      :ok
    end)
  end

  defp adapter(repo), do: repo.__adapter__()

  defp execute_and_log(repo, action, tenant, fun) do
    start = System.monotonic_time()
    result = fun.()
    stop = System.monotonic_time()

    :telemetry.execute(
      [:samiti, :tenant, String.to_atom(action)],
      %{duration: System.convert_time_unit(stop - start, :native, :millisecond)},
      %{tenant: tenant, repo: repo}
    )

    result
  end
end

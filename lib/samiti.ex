defmodule Samiti do
  @moduledoc """
  Samiti provides functions to manage tenant isolation.

  It supports creating and dropping tenant containers (Postgres Schemas or MySQL Databases)
  and running migrations for specific tenants.
  """

  @doc """
  Creates a new tenant container.

  For Postgres, it creates a new Schema.
  For MySQL, it creates a new Database.
  """
  def create(repo, name) do
    case adapter(repo) do
      Ecto.Adapters.Postgres ->
        repo.query!("CREATE SCHEMA \"#{name}\"")
        :ok

      Ecto.Adapters.MyXQL ->
        repo.query!("CREATE DATABASE `${name}`")
        :ok
    end
  end

  @doc """
  Drops a tenant container.

  For Postgres, it drops the Schema.
  For MySQL, it drops the Database.
  """
  def drop(repo, name) do
    case adapter(repo) do
      Ecto.Adapters.Postgres ->
        repo.query!("DROP SCHEMA \"#{name}\" CASCADE")
        :ok

      Ecto.Adapters.MyXQL ->
        repo.query!("DROP DATABASE `${name}`")
        :ok
    end
  end

  @doc """
  Runs migrations for a specific tenant.
  """
  def migrate(repo, name, migration_path) do
    Ecto.Migrator.run(repo, migration_path, :up, all: true, prefix: name)
  end

  defp adapter(repo), do: repo.__adapter__()
end

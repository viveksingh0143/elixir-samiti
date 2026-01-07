defmodule Samiti.DbTest do
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
  test "Postgres: executes 'CREATE SCHEMA' syntax", %{repo: repo} do
    assert :ok == Samiti.create(repo, "acme_schema")
  end

  # @tag :mysql
  # test "MySQL: executes 'CREATE DATABASE' syntax", %{repo: repo} do
  #   assert :ok == Samiti.create(repo, "acme_db")
  # end

  @tag :postgres
  test "Postgres: handles drop with CASCADE", %{repo: repo} do
    Samiti.create(repo, "to_drop")
    assert :ok == Samiti.drop(repo, "to_drop")
  end

  # @tag :mysql
  # test "MySQL: handles drop", %{repo: repo} do
  #   Samiti.create(repo, "to_drop")
  #   assert :ok == Samiti.drop(repo, "to_drop")
  # end
end

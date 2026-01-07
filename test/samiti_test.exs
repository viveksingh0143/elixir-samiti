defmodule SamitiTest do
  use ExUnit.Case, async: true
  # alias Samiti.Utils

  doctest Samiti

  # setup context do
  #   # Clear process dictionary state
  #   on_exit(fn -> Samiti.put_tenant(nil) end)

  #   # Database selection logic
  #   repo =
  #     cond do
  #       context[:postgres] -> Samiti.TestRepo.Postgres
  #       context[:mysql] -> Samiti.TestRepo.MySQL
  #       true -> nil
  #     end

  #   if repo do
  #     start_supervised!(repo)
  #     Ecto.Adapters.SQL.Sandbox.checkout(repo)
  #   end

  #   {:ok, repo: repo}
  # end

  # describe "state management" do
  #   test "put_tenant/1 and get_tenant/0" do
  #     Samiti.put_tenant("tenant_a")
  #     assert Samiti.get_tenant() == "tenant_a"
  #   end

  #   test "scope_global/1 bypasses current tenant" do
  #     Samiti.put_tenant("tenant_a")

  #     Samiti.scope_global(fn ->
  #       assert Samiti.get_tenant() == nil
  #     end)

  #     assert Samiti.get_tenant() == "tenant_a"
  #   end
  # end

  # describe "database operations" do
  #   @tag :postgres
  #   test "create/2 generates correct Postgres schema" do
  #     repo = Samiti.TestRepo.Postgres
  #     start_supervised!(repo)
  #     assert :ok == Samiti.create(repo, "test_schema")
  #   end

  #   @tag :mysql
  #   test "create/2 generates correct MySQL database" do
  #     repo = Samiti.TestRepo.MySQL
  #     start_supervised!(repo)
  #     assert :ok == Samiti.create(repo, "test_db")
  #   end
  # end

  # test "creates and drops a postgres schema" do
  #   tenant_name = "test_tenant_#{System.unique_integer([:positive])}"

  #   assert :ok = Samiti.create(TestRepo, tenant_name)

  #   result =
  #     TestRepo.query!(
  #       "SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1",
  #       [tenant_name]
  #     )

  #   assert result.num_rows == 1

  #   assert :ok = Samiti.drop(TestRepo, tenant_name)

  #   result =
  #     TestRepo.query!(
  #       "SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1",
  #       [tenant_name]
  #     )

  #   assert result.num_rows == 0
  # end
end

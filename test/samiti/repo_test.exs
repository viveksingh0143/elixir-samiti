defmodule Samiti.RepoTest do
  use ExUnit.Case, async: true
  import Ecto.Query

  # We use the Postgres TestRepo which uses Samiti.Repo
  alias Samiti.TestRepo.Postgres, as: TestRepo

  setup do
    on_exit(fn -> Samiti.put_tenant(nil) end)
    :ok
  end

  describe "prepare_query/3" do
    test "adds prefix when tenant is set" do
      Samiti.put_tenant("tenant_1")
      query = from(u in "users", select: u.id)
      opts = []

      {_query, new_opts} = TestRepo.prepare_query(:all, query, opts)

      assert new_opts[:prefix] == "tenant_1"
    end

    test "does not add prefix when tenant is nil" do
      Samiti.put_tenant(nil)
      query = from(u in "users", select: u.id)
      opts = []

      {_query, new_opts} = TestRepo.prepare_query(:all, query, opts)

      # Keyword.get returns nil if key missing
      assert new_opts[:prefix] == nil
    end

    test "skips prefix when skip_tenant: true is provided" do
      Samiti.put_tenant("tenant_1")
      query = from(u in "users", select: u.id)
      opts = [skip_tenant: true]

      {_query, new_opts} = TestRepo.prepare_query(:all, query, opts)

      assert new_opts[:prefix] == nil
      assert new_opts[:skip_tenant] == true
    end

    test "preserves other options" do
      Samiti.put_tenant("tenant_1")
      query = from(u in "users", select: u.id)
      opts = [timeout: 5000]

      {_query, new_opts} = TestRepo.prepare_query(:all, query, opts)

      assert new_opts[:prefix] == "tenant_1"
      assert new_opts[:timeout] == 5000
    end
  end
end

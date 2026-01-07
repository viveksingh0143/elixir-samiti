defmodule Samiti.FunctionalTest do
  use ExUnit.Case, async: true
  alias Samiti.Utils

  setup do
    on_exit(fn -> Samiti.put_tenant(nil) end)
  end

  describe "naming and pluralization" do
    test "converts strings to consistent naming maps" do
      results = Utils.naming_conventions("Organization")
      assert results.singular == "organization"
      assert results.plural == "organizations"
      assert results.module == "Organization"
    end

    test "handles atom inputs for configuration compatibility" do
      results = Utils.naming_conventions(:project)
      assert results.singular == "project"
      assert results.plural == "projects"
      assert results.module == "Project"
    end
  end

  describe "process state" do
    test "correctly stores and retrieves tenant in process dictionary" do
      Samiti.put_tenant("tenant_123")
      assert Samiti.get_tenant() == "tenant_123"
    end

    test "scope_global/1 isolation" do
      Samiti.put_tenant("tenant_a")

      Samiti.scope_global(fn ->
        assert Samiti.get_tenant() == nil
      end)

      assert Samiti.get_tenant() == "tenant_a"
    end
  end
end

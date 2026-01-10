defmodule SamitiTest do
  use ExUnit.Case, async: true
  doctest Samiti

  describe "state management" do
    test "put_tenant/1 and get_tenant/0" do
      Samiti.put_tenant("tenant_a")
      assert Samiti.get_tenant() == "tenant_a"
    end

    test "scope_global/1 bypasses current tenant" do
      Samiti.put_tenant("tenant_a")

      Samiti.scope_global(fn ->
        assert Samiti.get_tenant() == nil
      end)

      assert Samiti.get_tenant() == "tenant_a"
    end
  end
end

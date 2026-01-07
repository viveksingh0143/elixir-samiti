defmodule Samiti.PlugTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn

  # Setup to clear the tenant state after every test to prevent leakage
  setup do
    on_exit(fn -> Samiti.put_tenant(nil) end)

    # Mocking the application config for the test environment
    Application.put_env(:samiti, :admin_host, "localhost")
    :ok
  end

  describe "tenant resolution" do
    test "successfully resolves tenant from a subdomain" do
      # Simulate a request to 'apple.lvh.me'
      conn =
        conn(:get, "/")
        |> struct!(host: "apple.lvh.me")
        |> Samiti.Plug.call([])

      # 1. Check Process Dictionary (for DB scoping)
      assert Samiti.get_tenant() == "apple"

      # 2. Check Conn Assigns (for UI/View usage)
      assert conn.assigns.current_tenant_prefix == "apple"

      # 3. Check Response Headers (for debugging/API clients)
      assert get_resp_header(conn, "x-tenant-id") == ["apple"]
    end

    test "ignores resolution when the host matches the admin_host" do
      # Simulate a request to the main admin dashboard
      conn =
        conn(:get, "/")
        |> struct!(host: "localhost")
        |> Samiti.Plug.call([])

      assert Samiti.get_tenant() == nil
      assert conn.assigns[:current_tenant_prefix] == nil
    end

    test "handles complex subdomains by taking the first segment" do
      _conn =
        conn(:get, "/")
        |> struct!(host: "staging.tenant-name.example.com")
        |> Samiti.Plug.call([])

      # Based on your split(".") logic, this picks the first part
      assert Samiti.get_tenant() == "staging"
    end
  end

  describe "edge cases" do
    test "does not crash on IP-based hosts" do
      _conn =
        conn(:get, "/")
        |> struct!(host: "127.0.0.1")
        |> Samiti.Plug.call([])

      assert Samiti.get_tenant() == nil
    end
  end
end

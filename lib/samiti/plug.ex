defmodule Samiti.Plug do
  @moduledoc """
  A Plug to extract the tenant from the request.

  It expects the tenant to be the first part of the hostname (subdomain).
  It sets the tenant in the process dictionary as `:samiti_prefix` and
  in `conn.assigns` as `:current_tenant_prefix`.
  """
  import Plug.Conn

  @doc """
  Initializes the plug.
  """
  def init(opts), do: opts

  @doc """
  Extracts the tenant and assigns it.
  """
  def call(conn, _opts) do
    case resolve_tenant(conn) do
      nil ->
        conn

      tenant ->
        Samiti.put_tenant(tenant)

        conn
        |> assign(:current_tenant_prefix, tenant)
        |> put_resp_header("x-tenant-id", tenant)
    end
  end

  defp resolve_tenant(conn) do
    IO.inspect(label: "HOST SEGMENTS")

    conn.host
    |> IO.inspect(label: "HOST")
    |> String.split(".")
    |> IO.inspect(label: "HOST SEGMENTS")
    |> case do
      [tenant, _domain, _tld] -> tenant
      _ -> nil
    end
  end
end

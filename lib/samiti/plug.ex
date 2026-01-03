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
    case extract_tenant(conn) do
      nil ->
        conn

      tenant ->
        Process.put(:samiti_prefix, tenant)
        assign(conn, :current_tenant_prefix, tenant)
    end
  end

  defp extract_tenant(conn) do
    conn.host |> String.split(".") |> List.first()
  end
end

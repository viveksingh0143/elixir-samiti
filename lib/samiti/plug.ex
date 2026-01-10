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
    host = conn.host
    admin_host = Application.get_env(:samiti, :admin_host)

    cond do
      # 1. Admin Host Check
      host == admin_host ->
        nil

      # Edge case: IP address validation (prevents false positives like "127")
      match_ip?(host) ->
        nil

      # 2. Primary Domain & 3. Custom Domain Check
      # Both strategies currently rely on extracting the first segment.
      true ->
        extract_first_segment(host)
    end
  end

  defp extract_first_segment(host) do
    # Robust pattern for extracting first segment regardless of domain length
    case String.split(host, ".") do
      [tenant | rest] when rest != [] -> tenant
      _ -> nil
    end
  end

  defp match_ip?(host) do
    case :inet.parse_address(String.to_charlist(host)) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end

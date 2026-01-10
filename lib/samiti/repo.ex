defmodule Samiti.Repo do
  defmacro __using__(_opts) do
    quote do
      @doc """
      Callback implementation for `Ecto.Repo.prepare_query/3`.
      Automatically adds the tenant prefix if a tenant is set in the process dictionary.
      Can be skipped by passing `skip_tenant: true` in options.
      """
      def prepare_query(_operation, query, opts) do
        tenant = Samiti.get_tenant()

        if tenant && !opts[:skip_tenant] do
          {query, [prefix: tenant] ++ opts}
        else
          {query, opts}
        end
      end
    end
  end
end

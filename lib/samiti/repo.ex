defmodule Samiti.Repo do
  defmacro __using__(_opts) do
    quote do
      def default_options(_operation) do
        case Samiti.get_tenant() do
          nil -> []
          prefix -> [prefix: prefix]
        end
      end
    end
  end
end

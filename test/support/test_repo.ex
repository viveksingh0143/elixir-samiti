defmodule Samiti.TestRepo do
  use Ecto.Repo,
    otp_app: :samiti,
    adapter: Ecto.Adapters.Postgres
end

defmodule Samiti.TestRepo.Postgres do
  use Ecto.Repo, otp_app: :samiti, adapter: Ecto.Adapters.Postgres
  use Samiti.Repo
end

defmodule Samiti.TestRepo.MySQL do
  use Ecto.Repo, otp_app: :samiti, adapter: Ecto.Adapters.MyXQL
  use Samiti.Repo
end

ExUnit.start()

# Start Repos
# We start the repositories here to ensure they are available for all tests.
# The Sandbox mode is set to :manual so tests can checkout connections explicitly.
for repo <- [Samiti.TestRepo.Postgres, Samiti.TestRepo.MySQL] do
  try do
    {:ok, _} = repo.start_link()
    Ecto.Adapters.SQL.Sandbox.mode(repo, :manual)
  rescue
    e -> IO.puts("Could not start #{inspect(repo)}: #{inspect(e)}")
  end
end

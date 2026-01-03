import Config

config :samiti, Samiti.TestRepo,
  database: "samiti_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

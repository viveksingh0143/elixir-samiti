import Config

config :samiti,
  admin_host: "admin.myapp.com",
  primary_domain: "myapp.com",
  tenant_model: Samiti.Test.Organization

config :samiti, Samiti.TestRepo.Postgres,
  database: "samiti_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :samiti, Samiti.TestRepo.MySQL,
  database: "samiti_test",
  username: "root",
  password: "root",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

import Config

config :samiti, ecto_repos: [Samiti.TestRepo]
import_config "#{config_env()}.exs"

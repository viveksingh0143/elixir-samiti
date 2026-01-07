defmodule Samiti.MixProject do
  use Mix.Project

  def project do
    [
      app: :samiti,
      version: "0.1.0",
      description: "A multi-tenancy library for Phoenix with schema-based isolation.",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      source_url: "https://github.com/viveksingh0143/elixir-samiti.git"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Core database logic
      {:ecto_sql, "~> 3.13"},
      {:jason, "~> 1.4"},
      {:phoenix, "~> 1.7", optional: true},
      {:plug, "~> 1.19"},
      # Test & Dev only
      {:postgrex, "~> 0.21", optional: true},
      {:myxql, "~> 0.8", optional: true},
      {:ex_doc, "~> 0.39", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      # test: ["ecto.create --quiet -r Samiti.TestRepo.Postgres", "test"]
    ]
  end

  defp package() do
    [
      name: "samiti",
      maintainers: ["Vivek Singh"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/viveksingh0143/elixir-samiti.git"},
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE*)
    ]
  end
end

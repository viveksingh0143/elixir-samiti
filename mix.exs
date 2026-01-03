defmodule Samiti.MixProject do
  use Mix.Project

  def project do
    [
      app: :samiti,
      version: "0.1.0",
      description: "A simple multi-tenancy library for Ecto.",
      package: [
        maintainers: ["Vivek Singh"],
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => "https://github.com/yourname/samiti"}
      ],
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      deps: deps()
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
      {:ecto_sql, "~> 3.13"},
      {:plug_cowboy, "~> 2.7"},

      # Only for local library testing
      {:postgrex, "~> 0.21.1", only: :test},
      {:myxql, "~> 0.8.0", only: :test},
      {:ex_doc, "~> 0.39.3", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end

defmodule Samiti.Utils do
  @moduledoc false

  @doc "Detects the current project name as a string (e.g., 'ignis')"
  def app_name do
    to_string(Mix.Project.config()[:app])
  end

  @doc "Detects the current project module as a string (e.g., 'Ignis')"
  def app_module do
    app_name() |> Macro.camelize()
  end

  @doc "Simple pluralization logic"
  def pluralize(name) do
    Inflex.pluralize(name)
  end

  @doc """
  Generates singular, plural, and module names from a raw string.
  Returns a Map.
  """
  def naming_conventions(raw_name) do
    singular = String.downcase(String.trim(raw_name))

    %{
      singular: singular,
      plural: pluralize(singular),
      module: Macro.camelize(singular)
    }
  end

  @doc "Generates a timestamp for migrations: YYYYMMDDHHMMSS"
  def timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.local_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  @doc "Smart prompt that loops until a value is provided"
  def prompt_required(question) do
    answer = Mix.shell().prompt("#{question}:") |> String.trim()

    if answer == "" do
      Mix.shell().error("Error: This field is required.")
      prompt_required(question)
    else
      answer
    end
  end

  @doc "Smart prompt with a default value in brackets"
  def prompt(question, default) do
    answer = Mix.shell().prompt("#{question} [#{default}]:") |> String.trim()
    if answer == "", do: default, else: answer
  end

  defp pad(n), do: String.pad_leading("#{n}", 2, "0")
end

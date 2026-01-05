defmodule Mix.Tasks.Samiti.Setup do
  alias Samiti.Utils
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates multi-tenancy infrastructure based on your preferred naming"

  def run(_args) do
    # 1. Gather User Preferences
    resource_raw_name = Utils.prompt("What do you want to call your tenant/samiti?", "Tenant")
    use_binary_id = Mix.shell().yes?("Do you want to use binary_id (UUID)?")
    admin_host = Utils.prompt("What is your Admin Host?", "localhost")
    _need_liveviews = Mix.shell().yes?("Do you want to use generate live views for CRUD?")

    app_name = Utils.app_name()
    app_module = Utils.app_module()

    %{
      singular: resource_singular,
      plural: resource_plural,
      module: resource_module
    } = Utils.naming_conventions(resource_raw_name)

    # 2. Define paths
    migration_folder = "priv/repo/#{resource_singular}_migrations"
    model_path = "lib/#{app_name}/#{resource_singular}.ex"

    # 3. Create Custom Folders
    Mix.shell().info("Creating #{migration_folder}...")
    File.mkdir_p!(migration_folder)

    # 4. Generate the Model (Schema)
    generate_model(model_path, app_module, resource_module, resource_plural, use_binary_id)

    # 5. Generate the Migration for the central table
    generate_public_migration(app_module, resource_plural, resource_module, use_binary_id)

    # 6. Update Config
    update_config(admin_host, resource_singular, use_binary_id)

    Mix.shell().info("""

    ✔ Setup Complete!
    - Created Model: #{model_path}
    - Created Migration: priv/repo/migrations/xxxx_create_#{resource_plural}.exs
    - Created Tenant Migration Folder: #{migration_folder}
    - Updated config/config.exs with Admin Host: #{admin_host}
    """)
  end

  defp generate_model(path, app_module, module, table, use_binary_id) do
    binary_id_config =
      if use_binary_id do
        """
        @primary_key {:id, :binary_id, autogenerate: true}
        @foreign_key_type :binary_id
        """
      else
        ""
      end

    content = """
    defmodule #{app_module}.#{module} do
      use Ecto.Schema
      import Ecto.Changeset
      #{binary_id_config}
      @derive {Phoenix.Param, key: :id}
      schema "#{table}" do
        field :name, :string
        field :slug, :string
        field :host, :string
        timestamps()
      end

      def changeset(struct, attrs) do
        struct
        |> cast(attrs, [:name, :slug, :host])
        |> validate_required([:name, :slug])
        |> unique_constraint(:slug)
      end
    end
    """

    create_file(path, content)
  end

  defp generate_public_migration(app_module, table, module, use_binary_id) do
    timestamp = SimpleTimestamp.now()
    path = "priv/repo/migrations/#{timestamp}_create_#{table}.exs"

    table_opts =
      if use_binary_id, do: ", primary_key: false", else: ""

    field_id = if use_binary_id, do: "add :id, :binary_id, primary_key: true", else: ""

    content = """
    defmodule #{app_module}.Repo.Migrations.Create#{module} do
      use Ecto.Migration

      def change do
        create table(:#{table}#{table_opts}) do
          #{field_id}
          add :name, :string, null: false
          add :slug, :string, null: false
          add :host, :string
          timestamps()
        end

        create unique_index(:#{table}, [:slug])
      end
    end
    """

    create_file(path, content)
  end

  defp update_config(host, resource, use_binary_id) do
    config_path = "config/config.exs"

    new_confg = """
    config :samiti,
      admin_host: "#{host}",
      tenant_resource: :#{resource},
      binary_id: #{use_binary_id}
    """

    File.write!(config_path, new_confg, [:append])
  end
end

defmodule SimpleTimestamp do
  def now do
    {{y, m, d}, {hh, mm, ss}} = :calendar.local_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(n), do: String.pad_leading("#{n}", 2, "0")
end

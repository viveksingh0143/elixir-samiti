defmodule Mix.Tasks.Samiti.Setup do
  alias Samiti.Utils
  use Mix.Task

  @shortdoc "Generates multi-tenancy infrastructure based on your preferred naming"

  def run(_args) do
    # 1. Gather User Preferences
    resource_raw_name = Utils.prompt("What do you want to call your tenant/samiti?", "Tenant")
    use_binary_id = Mix.shell().yes?("Do you want to use binary_id (UUID)?")
    admin_host = Utils.prompt("What is your Admin Host?", "localhost")
    need_liveviews = Mix.shell().yes?("Do you want to use generate live views for CRUD?")

    app_name = Utils.app_name()
    app_module = Utils.app_module()
    naming = Utils.naming_conventions(resource_raw_name)

    # 2. Setup Assigns for Templates
    assigns = [
      app_name: app_name,
      app_module: app_module,
      resource: naming.singular,
      module: naming.module,
      table: naming.plural,
      use_binary_id: use_binary_id
    ]

    # 3. Define paths
    template_dir = Path.join([Application.app_dir(:samiti), "priv", "templates", "samiti.setup"])
    migration_folder = "priv/repo/#{assigns[:resource]}_migrations"
    model_path = "lib/#{app_name}/#{assigns[:resource]}.ex"

    File.mkdir_p!(migration_folder)
    Mix.shell().info("Created #{migration_folder} directory...")

    # 4. Generate Model File using EEx Templates
    Utils.generate_file_by_template(
      template_dir,
      "model.ex.eex",
      model_path,
      assigns
    )

    Mix.shell().info("✔ Generated Model at #{model_path}")

    # 5. Generate Migration File using EEx Templates
    timestamp = Utils.now_timestamp()
    migration_path = "priv/repo/migrations/#{timestamp}_create_#{assigns[:table]}.exs"

    Utils.generate_file_by_template(
      template_dir,
      "migration.ex.eex",
      migration_path,
      assigns
    )

    Mix.shell().info("✔ Generated migration at #{migration_path}")
    # 6. Update Config
    update_config(admin_host, assigns[:resource], use_binary_id)

    Mix.shell().info("""

    ✔ Setup Complete!
    - Created Model: #{model_path} #{if use_binary_id, do: "with binary_id", else: ""}
    - Created Migration #{if use_binary_id, do: "(with binary_id)", else: ""}: priv/repo/migrations/xxxx_create_#{assigns[:table]}.exs
    - Created Tenant Migration Folder: #{migration_folder}
    - Updated config/config.exs with Admin Host: #{admin_host}
    - Live Views #{if need_liveviews, do: "Generated", else: "Skipped"}
    """)
  end

  defp update_config(host, resource, use_binary_id) do
    config_path = "config/config.exs"

    if File.exists?(config_path) do
      original_content = File.read!(config_path)

      new_confg = """
      config :samiti,
        admin_host: "#{host}",
        tenant_resource: :#{resource},
        binary_id: #{use_binary_id}

      """

      if String.contains?(original_content, "config :samiti") do
        Mix.shell().info("Config for :samiti already exists. Skipping updates.")
      else
        pattern = ~r/import_config\s+"\#\{config_env\(\)\}\.exs"/

        updated_content =
          if String.match?(original_content, pattern) do
            String.replace(original_content, pattern, "#{new_confg}\\0")
          else
            original_content <> "\n" <> new_confg
          end

        File.write!(config_path, updated_content)
      end
    else
      Mix.shell().error("Could not find config/config.exs")
    end
  end
end

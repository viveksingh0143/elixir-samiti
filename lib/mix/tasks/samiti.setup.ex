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

    # 7. Conditionally call the LiveView Generator
    if need_liveviews do
      Mix.shell().info("Triggering LiveView generation...")
      Mix.Tasks.Samiti.Gen.Live.run([])
    end

    # 8. Print summary
    print_summary(naming, admin_host, use_binary_id, migration_path, model_path)
  end

  defp update_config(host, resource, use_binary_id) do
    config_path = "config/config.exs"

    Application.put_env(:samiti, :admin_host, host)
    Application.put_env(:samiti, :tenant_resource, resource)
    Application.put_env(:samiti, :binary_id, use_binary_id)

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

  defp print_summary(naming, admin_host, use_binary_id, migration_path, model_path) do
    Mix.shell().info("""
    #{IO.ANSI.green()}✔ Samiti Setup Complete!#{IO.ANSI.reset()}
    #{IO.ANSI.yellow()}Summary:#{IO.ANSI.reset()}
    • Resource: :#{naming.singular}
    • Admin Host: #{admin_host}
    • Binary ID: #{use_binary_id}
    • Migration Path: #{migration_path}
    • Model Path: #{model_path}
    """)
  end
end

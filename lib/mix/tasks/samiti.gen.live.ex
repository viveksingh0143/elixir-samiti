defmodule Mix.Tasks.Samiti.Gen.Live do
  use Mix.Task
  alias Samiti.Utils

  @shortdoc "Generate LiveView CRUD for your tenant resource"

  def run(_args) do
    resource = Utils.get_config_or_fail(:tenant_resource)
    naming = Utils.naming_conventions(resource)
    app_name = Utils.app_name()
    app_module = Utils.app_module()

    assigns = [
      app_name: app_name,
      app_module: app_module,
      module: naming.module,
      singular: naming.singular,
      plural: naming.plural
    ]

    template_dir =
      Path.join([Application.app_dir(:samiti), "priv", "templates", "samiti.gen.live"])

    target_path = "lib/#{app_name}_web/live/#{naming.singular}_live"
    File.mkdir_p!(target_path)

    list_path = "#{target_path}/index.ex"

    Utils.generate_file_by_template(
      template_dir,
      "index.ex.eex",
      list_path,
      assigns
    )

    Mix.shell().info("✔ Generated LiveView Index at #{target_path}/index.ex")

    form_path = "#{target_path}/form_component.ex"

    Utils.generate_file_by_template(
      template_dir,
      "form_component.ex.eex",
      form_path,
      assigns
    )

    Mix.shell().info("✔ Generated LiveView FormComponent at #{target_path}/form_component.ex")

    print_summary(app_name, app_module, naming, list_path, form_path)
  end

  defp print_summary(app_name, app_module, naming, list_path, form_path) do
    Mix.shell().info("""
    #{IO.ANSI.green()}✔ Live View Generation Complete!#{IO.ANSI.reset()}
    #{IO.ANSI.yellow()}Summary:#{IO.ANSI.reset()}
    • List File: :#{list_path}
    • Form File: #{form_path}

    #{IO.ANSI.magenta()}Next Step: Add routes to your lib/#{app_name}_web/router.ex:#{IO.ANSI.reset()}
    scope "/", #{app_module}Web do
      pipe_through :browser

      live "/#{naming.plural}", #{naming.module}Live.Index, :index
      live "/#{naming.plural}/new", #{naming.module}Live.Index, :new
      live "/#{naming.plural}/:#{naming.singular}", #{naming.module}Live.Index, :edit
    end
    """)
  end
end

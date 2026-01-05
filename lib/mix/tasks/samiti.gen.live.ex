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

    Utils.generate_file_by_template(
      template_dir,
      "index.ex.eex",
      "#{target_path}/index.ex",
      assigns
    )

    Mix.shell().info("✔ Generated LiveView Index at #{target_path}/index.ex")

    Utils.generate_file_by_template(
      template_dir,
      "form_component.ex.eex",
      "#{target_path}/form_component.ex",
      assigns
    )

    Mix.shell().info("✔ Generated LiveView FormComponent at #{target_path}/form_component.ex")
  end
end

# # # lib/ignis_web/telemetry.ex
# # :telemetry.attach(
# #   "samiti-handler",
# #   [:samiti, :tenant, :create],
# #   fn _event, measurements, metadata, _config ->
# #     Logger.info("[Samiti] Created tenant #{metadata.tenant} in #{measurements.duration}ns")
# #   end,
# #   nil
# # )

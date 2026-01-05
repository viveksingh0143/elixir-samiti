defmodule Mix.Tasks.Samiti.Gen.Live do
  use Mix.Task
  import Mix.Generator

  def run(_args) do
    resource = Application.get_env(:samiti, :tenant_resource) || :tenant
    module_name = Macro.camelize(to_string(resource))

    Mix.shell().info("Generating LiveView for #{module_name}...")

    # In a real package, you would use EEx.eval_file here to load templates
    # for index.ex, form_component.ex, and show.ex.
    # These would use Samiti.create/2 and Samiti.migrate/3 in the 'save' logic.

    create_file(
      "lib/your_app_web/live/#{resource}_live/index.ex",
      "defmodule YourAppWeb.#{module_name}Live.Index do ... end"
    )
  end
end

# # lib/ignis_web/telemetry.ex
# :telemetry.attach(
#   "samiti-handler",
#   [:samiti, :tenant, :create],
#   fn _event, measurements, metadata, _config ->
#     Logger.info("[Samiti] Created tenant #{metadata.tenant} in #{measurements.duration}ns")
#   end,
#   nil
# )

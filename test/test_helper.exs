ExUnit.start()

# Load all support files, except the helper files like *_helper.{ex,exs}, test_helper.exs
# File.ls!("test/support")
# |> Enum.each(&Code.require_file("test/support/#{&1}"))

env = Mix.env()
Mix.shell().info("env: #{env}")

# if Mix.env() == :test do
#   "test/support/**/*.{ex,exs}"
#   |> Path.wildcard()
#   |> Enum.reject(&helper_file?/1)
#   |> Enum.sort()
#   |> Enum.each(&Code.require_file/1)
# end

# defp helper_file?(path) do
#   String.ends_with?(path, [
#     "_helper.ex",
#     "_helper.exs",
#     "test_helper.exs"
#   ])
# end

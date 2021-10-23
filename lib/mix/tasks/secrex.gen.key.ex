defmodule Mix.Tasks.Secrex.Gen.Key do
  @moduledoc """
  Generates a secret key.
  """

  use Mix.Task

  @shortdoc "Generates a secret key"

  @switches [file_path: :string]
  @aliases [f: :file_path]

  @impl true
  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {options, []} ->
        key = 32 |> :crypto.strong_rand_bytes() |> Base.encode64(padding: false)
        key_path = Keyword.get(options, :file_path, ".secret-key")

        created? =
          key_path
          |> Path.expand()
          |> Mix.Generator.create_file(key)

        if created? do
          Mix.shell().info("""
          Don't forget to add it to your configuration files,
          so other Secrex Mix tasks works as expected:

              config :secrex,
                key_path: #{inspect(key_path)}
          """)
        end

      {_, args} ->
        Mix.raise("Expected \"mix secrex.gen.key\" without arguments, got: #{inspect(args)}")
    end
  end
end

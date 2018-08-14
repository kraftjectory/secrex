defmodule Mix.Tasks.Secrex.Encrypt do
  use Mix.Task

  import Mix.Secrex

  @shortdoc "Encrypt secret files"

  def run(_args) do
    key = encryption_key()

    for path <- secret_files() do
      Mix.shell().info("encrypting #{path}")
      encrypted = encrypt(path, key)
      File.write!(encrypted_path(path), encrypted)
    end

    Mix.shell().info("files encrypted")
  end
end

defmodule Mix.Tasks.Secrex.Encrypt do
  use Mix.Task

  import Mix.Secrex

  @shortdoc "Encrypt secret files"

  def run(_args) do
    {key_type, key} = get_encryption_key()

    for path <- secret_files() do
      Mix.shell().info("encrypting #{path}")
      encrypted = encrypt(path, key)
      File.write!(encrypted_path(path), encrypted)
    end

    if key_type == :trimmed_key do
      Mix.shell().info(
        "your key was trimmed because keyfile contained spaces or newline characters"
      )

      write_encryption_key(key)

      Mix.shell().info("keyfile updated with trimmed key")
    end

    Mix.shell().info("files encrypted")
  end
end

defmodule Mix.Tasks.Secrex.Decrypt do
  use Mix.Task

  import Mix.Secrex

  @shortdoc "Decrypts secret files"

  @moduledoc "Decrypts secret files"

  @impl true
  def run(_args) do
    key = encryption_key()

    for path <- secret_files() do
      enc_path = encrypted_path(path)
      Mix.shell().info("decrypting #{enc_path}")
      decrypted = decrypt(enc_path, key)
      File.write!(path, decrypted)
    end

    Mix.shell().info("files decrypted")
  end
end

defmodule Mix.Tasks.Secrex.Decrypt do
  @moduledoc """
  Decrypts secrets to the configured files.
  """

  use Mix.Task

  import Mix.Secrex

  @shortdoc "Decrypts secrets to the configured files"

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

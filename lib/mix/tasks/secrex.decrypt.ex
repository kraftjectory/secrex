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
      Mix.shell().info("Decrypting #{enc_path}")

      case decrypt(enc_path, key) do
        {:ok, decrypted} ->
          File.write!(path, decrypted)

        {:error, reason} ->
          Mix.raise("Cannot decrypt file, reason: " <> inspect(reason))
      end
    end

    Mix.shell().info("Files have been decrypted")
  end
end

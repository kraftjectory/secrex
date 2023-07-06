defmodule Mix.Tasks.Secrex.Decrypt do
  @moduledoc """
  Decrypts secrets to the configured files.
  """

  use Mix.Task

  import Mix.Secrex

  @shortdoc "Decrypts secrets to the configured files"

  @impl true
  def run(["--bucket", bucket]) do
    bucket
    |> String.to_atom()
    |> decrypt()
  end

  @impl true
  def run([]) do
    Enum.map(buckets(), &decrypt/1)
  end

  defp decrypt(bucket) do
    key = encryption_key(bucket)

    for path <- secret_files(bucket) do
      enc_path = encrypted_path(path)
      Mix.shell().info("Decrypting #{enc_path}")
      File.write!(path, decrypt(enc_path, key))
    end

    Mix.shell().info("Files have been decrypted")
  end
end

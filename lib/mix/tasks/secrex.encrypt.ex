defmodule Mix.Tasks.Secrex.Encrypt do
  @moduledoc """
  Encrypts secrets to the configured files.
  """

  use Mix.Task

  import Mix.Secrex

  @shortdoc "Encrypts secrets to the configured files"

  @impl true
  def run(["--bucket", bucket]) do
    bucket
    |> String.to_atom()
    |> encrypt()
  end

  @impl true
  def run([]) do
    Enum.map(buckets(), &encrypt/1)
  end

  defp encrypt(bucket) do
    key = encryption_key(bucket)

    for path <- secret_files(bucket) do
      Mix.shell().info("Encrypting #{path}")

      {:ok, encrypted} = encrypt(path, key)

      File.write!(encrypted_path(path), encrypted)
    end

    Mix.shell().info("Files have been encrypted")
  end
end

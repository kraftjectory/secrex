defmodule Mix.Tasks.Secrex.Decrypt do
  use Mix.Task

  import Mix.Secrex

  @shortdoc "Decrypt secret files"

  def run(_args) do
    {key_type, key} = get_encryption_key()

    Enum.each(secret_files(), fn path ->
      enc_path = encrypted_path(path)
      Mix.shell().info("decrypting #{enc_path}")
      decrypted = decrypt(enc_path, key)
      File.write!(path, decrypted)
    end)

    if key_type == :trimmed_key do
      Mix.shell().info(
        "your key was trimmed because keyfile contained spaces or newline characters"
      )

      write_encryption_key(key)

      Mix.shell().info("keyfile updated with trimmed key")
    end

    Mix.shell().info("files decrypted")
  end
end

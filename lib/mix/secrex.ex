defmodule Mix.Secrex do
  def secret_files() do
    Application.get_env(:secrex, :files)
  end

  def get_encryption_key() do
    case read_encryption_key() do
      {:ok, key} ->
        trim_key = String.trim(key)

        if key == trim_key, do: {:plain_key, key}, else: {:trimmed_key, trim_key}

      {:error, :no_key_file} ->
        {:console_key, get_password("Enter the encryption key:")}
    end
  end

  def secret_files_changed?() do
    {_, key} = get_encryption_key()

    Enum.any?(secret_files(), fn path ->
      enc_path = encrypted_path(path)
      decrypted = decrypt(enc_path, key)
      File.read!(path) != decrypted
    end)
  end

  def encrypted_path(path) do
    path <> ".enc"
  end

  def encrypt(path, key) do
    Secrex.AES.encrypt(File.read!(path), key)
  end

  def decrypt(path, key) do
    Secrex.AES.decrypt(File.read!(path), key)
  end

  def write_encryption_key(key) do
    File.write!(Application.get_env(:secrex, :key_file), key)
  end

  # Helpers
  defp read_encryption_key do
    case Application.get_env(:secrex, :key_file) do
      nil -> {:error, :no_key_file}
      key_path -> {:ok, File.read!(key_path)}
    end
  end

  # Hidden password input, stolen from hex.pm
  defp get_password(prompt) do
    pid = spawn_link(fn -> get_password_loop(prompt) end)
    ref = make_ref()
    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})
    receive do: ({:done, ^pid, ^ref} -> :ok)

    value
  end

  defp get_password_loop(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self(), ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt} ")
        get_password_loop(prompt)
    end
  end
end

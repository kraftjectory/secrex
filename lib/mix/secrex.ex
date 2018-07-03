defmodule Mix.Secrex do
  def secret_files() do
    Application.get_env(:secrex, :files)
  end

  def encryption_key() do
    key_path = Application.get_env(:secrex, :key_file)

    if key_path do
      File.read!(key_path)
    else
      get_password("Enter the encryption key:")
    end
  end

  def secret_files_changed?() do
    key = encryption_key()

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

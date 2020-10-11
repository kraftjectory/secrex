defmodule Mix.Secrex do
  @moduledoc """
  Utility functions to work with secret files.
  """

  @doc false
  def secret_files() do
    Application.get_env(:secrex, :files)
  end

  @doc false
  def encryption_key() do
    key_path = Application.get_env(:secrex, :key_file)

    if key_path do
      key_path |> Path.expand() |> File.read!()
    else
      get_password("Enter the encryption key:")
    end
  end

  @doc false
  def get_cipher() do
    Application.get_env(:secrex, :cipher, Secrex.AES)
  end

  @doc ~S"""
  Checks if the local decrypted files are in sync with the encrypted ones.

  This could be useful in deployment process. For instance, to abort deployment if secrets diverge:

      if Mix.Secrex.secret_files_changed?() do
        Mix.raise(
          "Secret files are not in sync. Please run \"mix secrex.decrypt\" to retrieve latest updates."
        )
      end

  """
  @spec secret_files_changed?() :: boolean()
  def secret_files_changed?() do
    key = encryption_key()

    Enum.any?(secret_files(), fn path ->
      enc_path = encrypted_path(path)
      decrypted = decrypt(enc_path, key)
      File.read!(path) != decrypted
    end)
  end

  @doc false
  def encrypted_path(path) do
    path <> ".enc"
  end

  @doc false
  def encrypt(path, key) do
    path |> File.read!() |> get_cipher().encrypt(key)
  end

  @doc false
  def decrypt(path, key) do
    case get_cipher().decrypt(File.read!(path), key) do
      {:ok, decrypted} ->
        decrypted

      {:error, reason} ->
        Mix.raise("Cannot decrypt file, reason: " <> inspect(reason))
    end
  end

  # Hidden password input, taken from Hex.
  defp get_password(prompt) do
    pid = spawn_link(fn -> get_password_loop(prompt) end)
    ref = make_ref()
    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})

    receive do
      {:done, ^pid, ^ref} -> :ok
    end

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

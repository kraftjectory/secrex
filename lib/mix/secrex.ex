defmodule Mix.Secrex do
  @moduledoc """
  Utility functions to work with secret files.
  """

  @doc false
  def secret_files(bucket) do
    Application.get_env(:secrex, :buckets, [])
    |> Keyword.get(bucket, [])
    |> Keyword.get(:files, [])
  end

  @doc false
  def buckets() do
    :secrex
    |> Application.get_all_env()
    |> Keyword.get(:buckets, [])
    |> Keyword.keys()
  end

  @doc false
  def get_bucket(bucket) do
    :secrex
    |> Application.get_env(:buckets)
    |> Keyword.get(bucket, [])
  end

  @doc false
  def encryption_key(bucket) do
    key_path = bucket |> get_bucket() |> Keyword.get(:key_file)

    if key_path do
      key_path |> Path.expand() |> File.read!()
    else
      input_encryption_key("Enter the encryption key:")
    end
    |> String.trim_trailing()
  end

  @doc false
  def get_cipher() do
    Application.get_env(:secrex, :cipher, Secrex.AES)
  end

  @doc ~S"""
  Checks either the specified or all buckets decrypted files are in sync with the encrypted ones.

  This could be useful in deployment process. For instance, to abort deployment if secrets diverge:

      if Mix.Secrex.secret_files_changed?() do
        Mix.raise(
          "Secret files are not in sync. Please run \"mix secrex.decrypt\" to retrieve latest updates."
        )
      end

      if Mix.Secrex.secret_files_changed?(:my_bucket) do
        Mix.raise(
          "Secret files are not in sync. Please run \"mix secrex.decrypt --bucket my_bucket\" to retrieve latest updates."
        )
      end
  """
  @spec secret_files_changed?() :: boolean()
  def secret_files_changed?() do
    changed_files = Enum.map(buckets(), &do_secret_files_changed?/1)
    Enum.any?(changed_files)
  end

  @spec secret_files_changed?(bucket :: atom()) :: boolean()
  def secret_files_changed?(bucket) do
    do_secret_files_changed?(bucket)
  end

  defp do_secret_files_changed?(bucket) do
    key = encryption_key(bucket)

    Enum.any?(secret_files(bucket), fn path ->
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

  # Encryption key prompt that hides input; taken from Hex.
  defp input_encryption_key(prompt) do
    pid = spawn_link(fn -> input_loop(prompt) end)
    ref = make_ref()
    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})

    receive do
      {:done, ^pid, ^ref} -> :ok
    end

    value
  end

  defp input_loop(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self(), ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt} ")
        input_loop(prompt)
    end
  end
end

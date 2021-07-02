defmodule Secrex.AES do
  @moduledoc """
  This module is an implementation of Secrex.Cipher using AES256-GCM.

  ## Example

      iex> encryption_key = "very-secretive"
      iex> {:ok, encrypted} = Secrex.AES.encrypt("Hello, World!", encryption_key)
      iex> Secrex.AES.decrypt(encrypted, encryption_key)
      {:ok, "Hello, World!"}

  """

  alias Secrex.Cipher

  @behaviour Cipher

  # Additional Authenticated Data.
  @aad 'AES256GCM'

  @iv_length 16
  @tag_length 16

  @doc """
  Encrypts data using AES256-GCM.
  """
  @spec encrypt(Cipher.plaintext(), Cipher.key()) :: {:ok, Cipher.ciphertext()}
  @impl true
  def encrypt(plaintext, key) do
    init_vector = initialize_vector(@iv_length)
    key_digest = hash(key)

    {encrypted, tag} = :crypto.crypto_one_time_aead(:aes_gcm, key_digest, init_vector, plaintext, @aad, @tag_length, true)

    {:ok, init_vector <> tag <> encrypted}
  end

  @doc "Decrypts data using AES256-GCM"
  @spec decrypt(Cipher.ciphertext(), Cipher.key()) ::
          {:ok, Cipher.plaintext()}
          | {:error, :invalid_ciphertext | :incorrect_key_or_ciphertext}
  @impl true
  def decrypt(ciphertext, key) do
    key_digest = hash(key)

    case ciphertext do
      <<init_vector::size(@iv_length)-bytes, tag::size(@tag_length)-bytes, encrypted::binary>> ->
        case :crypto.crypto_one_time_aead(:aes_gcm, key_digest, init_vector, encrypted, @aad, tag, false) do
          :error ->
            {:error, :incorrect_key_or_ciphertext}

          plaintext ->
            {:ok, plaintext}
        end

      _ ->
        {:error, :invalid_ciphertext}
    end
  end

  defp hash(key), do: :crypto.hash(:sha256, key)

  defp initialize_vector(length), do: :crypto.strong_rand_bytes(length)
end

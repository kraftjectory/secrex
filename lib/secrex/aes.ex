defmodule Secrex.AES do
  @moduledoc false

  @behaviour Secrex.Cipher

  # Additional Authenticated Data.
  @aad "AES256GCM"

  @iv_length 16
  @tag_length 16

  @impl true
  def encrypt(plaintext, key) do
    init_vector = initialize_vector()
    hashed_key = hash(key)

    {encrypted, tag} =
      :crypto.block_encrypt(
        :aes_gcm,
        hashed_key,
        init_vector,
        {@aad, plaintext, @tag_length}
      )

    {:ok, init_vector <> tag <> encrypted}
  end

  @impl true
  def decrypt(ciphertext, key) do
    hashed_key = hash(key)

    case ciphertext do
      <<init_vector::binary-size(@iv_length), tag::binary-size(@tag_length), encrypted::binary>> ->
        plaintext = :crypto.block_decrypt(:aes_gcm, hashed_key, init_vector, {@aad, encrypted, tag})

        {:ok, plaintext}

      _ ->
        {:error, "invalid ciphertext"}
    end
  end

  defp hash(key), do: :crypto.hash(:sha256, key)

  defp initialize_vector(), do: :crypto.strong_rand_bytes(16)
end

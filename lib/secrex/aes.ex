defmodule Secrex.AES do
  @moduledoc false

  @behaviour Secrex.Cipher

  # Additional Authenticated Data.
  @aad "AES256GCM"

  @iv_length 16
  @tag_length 16

  @impl true
  def encrypt(plaintext, key) do
    init_vector = initialize_vector(@iv_length)
    key_digest = hash(key)

    {encrypted, tag} =
      :crypto.block_encrypt(
        :aes_gcm,
        key_digest,
        init_vector,
        {@aad, plaintext, @tag_length}
      )

    {:ok, init_vector <> tag <> encrypted}
  end

  @impl true
  def decrypt(ciphertext, key) do
    key_digest = hash(key)

    case ciphertext do
      <<init_vector::size(@iv_length)-bytes, tag::size(@tag_length)-bytes, encrypted::binary>> ->
        plaintext =
          :crypto.block_decrypt(:aes_gcm, key_digest, init_vector, {@aad, encrypted, tag})

        {:ok, plaintext}

      _ ->
        {:error, :invalid_ciphertext}
    end
  end

  defp hash(key), do: :crypto.hash(:sha256, key)

  defp initialize_vector(length), do: :crypto.strong_rand_bytes(length)
end

defmodule Secrex.AES.BlockEncrypt do
  @aad 'AES256GCM'
  @tag_length 16

  defmacro tag_length(), do: @tag_length

  # function_exported?(:crypto, :crypto_one_time_aead, 7) |> IO.inspect(label: "TEST")

  if Code.ensure_loaded?(:crypto) && function_exported?(:crypto, :crypto_one_time_aead, 7) do
    def block_encrypt(key_digest, init_vector, plaintext) do
      :crypto.crypto_one_time_aead(
        :aes_gcm,
        key_digest,
        init_vector,
        plaintext,
        @aad,
        @tag_length,
        true
      )
    end
  else
    def block_encrypt(key_digest, init_vector, plaintext) do
      :crypto.block_encrypt(
        :aes_gcm,
        key_digest,
        init_vector,
        {List.to_string(@aad), plaintext, @tag_length}
      )
    end
  end

  if Code.ensure_loaded?(:crypto) && function_exported?(:crypto, :crypto_one_time_aead, 7) do
    def block_decrypt(key_digest, init_vector, encrypted, tag) do
      :crypto.crypto_one_time_aead(
        :aes_gcm,
        key_digest,
        init_vector,
        encrypted,
        @aad,
        tag,
        false
      )
    end
  else
    def block_decrypt(key_digest, init_vector, encrypted, tag) do
      :crypto.block_decrypt(
        :aes_gcm,
        key_digest,
        init_vector,
        {List.to_string(@aad), encrypted, tag}
      )
    end
  end
end

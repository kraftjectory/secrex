defmodule Secrex.AES.BlockEncrypt do
  @moduledoc """
  Pick encryption and decryption based on availability of :crypto.block_encrypt/4
  and :crypto.block_decrypt/4 which were removed in OTP24.

  :crypto.crypto_one_time_aead/7 is available from OTP22, however the cipher :aes_gcm is not until OTP24,
  hence we use the deprecated versions as long as they're available.
  """

  @aad 'AES256GCM'
  @tag_length 16

  defmacro tag_length(), do: @tag_length

  # Use deprecated functions if they're available
  if Code.ensure_loaded?(:crypto) && function_exported?(:crypto, :block_encrypt, 4) do
    def block_encrypt(key_digest, init_vector, plaintext) do
      :crypto.block_encrypt(
        :aes_gcm,
        key_digest,
        init_vector,
        {List.to_string(@aad), plaintext, @tag_length}
      )
    end

    def block_decrypt(key_digest, init_vector, encrypted, tag) do
      :crypto.block_decrypt(
        :aes_gcm,
        key_digest,
        init_vector,
        {List.to_string(@aad), encrypted, tag}
      )
    end
  else
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
  end
end

defmodule Secrex.AES do
  def encrypt(input, key) do
    iv = :crypto.strong_rand_bytes(16)
    key = hash(key)
    {encrypted, tag} = :crypto.block_encrypt(:aes_gcm, key, iv, {"AES256GCM", input, 16})
    iv <> tag <> encrypted
  end

  def decrypt(encrypted, key) do
    key = hash(key)
    <<iv::binary-16, tag::binary-16, encrypted::binary>> = encrypted
    :crypto.block_decrypt(:aes_gcm, key, iv, {"AES256GCM", encrypted, tag})
  end

  defp hash(input), do: :crypto.hash(:sha256, input)
end

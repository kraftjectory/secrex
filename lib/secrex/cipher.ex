defmodule Secrex.Cipher do
  @type plaintext() :: iodata()
  @type ciphertext() :: iodata()
  @type key() :: iodata()

  @callback encrypt(plaintext(), key()) :: {:ok, ciphertext()} | {:error, reason :: atom()}
  @callback decrypt(ciphertext(), key()) :: {:ok, plaintext()} | {:error, reason :: atom()}
end

defmodule Secrex.AESTest do
  use ExUnit.Case, async: true

  alias Secrex.AES

  import ExUnitProperties
  import StreamData

  doctest Secrex.AES

  property "encrypt/2 and decrypt/2" do
    check all(
            plaintext <- binary(min_length: 1),
            key <- binary(min_length: 1)
          ) do
      assert {:ok, ciphertext} = AES.encrypt(plaintext, key)

      assert AES.decrypt(ciphertext, key) == {:ok, plaintext}

      incorrect_key = key <> "A"
      assert AES.decrypt(ciphertext, incorrect_key) == {:error, :incorrect_key_or_ciphertext}
    end
  end
end

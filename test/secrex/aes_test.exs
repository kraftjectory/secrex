defmodule Secrex.AESTest do
  use ExUnit.Case, async: true

  alias Secrex.AES

  import ExUnitProperties
  import StreamData
  import Bitwise

  doctest Secrex.AES

  property "encrypt/2 and decrypt/2" do
    check all(
            key <- binary(min_length: 1),
            plaintext <- binary(min_length: 1),
            aad <- binary()
          ) do
      assert {:ok, ciphertext} = AES.encrypt(plaintext, key, aad)

      assert AES.decrypt(ciphertext, key, aad) == {:ok, plaintext}

      incorrect_key = corrupt_binary(key)
      assert AES.decrypt(ciphertext, incorrect_key, aad) == {:error, :incorrect_key_or_ciphertext}

      incorrect_aad = corrupt_binary(aad)
      assert AES.decrypt(ciphertext, key, incorrect_aad) == {:error, :incorrect_key_or_ciphertext}
    end
  end

  defp corrupt_binary(value) do
    bit_position = :rand.uniform(bit_size(value) + 1) - 1

    bsl(1, bit_position)
    |> bxor(:binary.decode_unsigned(value))
    |> :binary.encode_unsigned()
  end
end

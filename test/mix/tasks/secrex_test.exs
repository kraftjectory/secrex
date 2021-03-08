defmodule Mix.Tasks.SecrexTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup :clean_up_directory

  setup do
    Application.put_env(:secrex, :key_file, "test/support/secret-key")
    Application.delete_env(:secrex, :files)
    Application.delete_env(:secrex, :cipher)
  end

  defmodule PlaintextCipher do
    @behaviour Secrex.Cipher

    @impl true
    def encrypt(plaintext, key) do
      send(self(), {:encrypt, key})

      {:ok, plaintext}
    end

    @impl true
    def decrypt(ciphertext, key) do
      send(self(), {:decrypt, key})

      {:ok, ciphertext}
    end
  end

  @secret_path "/tmp/secrex"

  test "encrypts and decrypts secrets to the configured files" do
    plaintext = "this is a secret"
    source_file = @secret_path <> Integer.to_string(System.system_time(:microsecond))

    File.mkdir!(@secret_path)
    File.write!(source_file, plaintext)

    Application.put_env(:secrex, :files, [source_file])

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Encrypt.run([])
      end)

    assert output =~ "Encrypting #{source_file}"
    assert output =~ "Files have been encrypted"

    File.rm!(source_file)
    assert File.read!(source_file <> ".enc") != plaintext

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Decrypt.run([])
      end)

    assert output =~ "Decrypting #{source_file}"
    assert output =~ "Files have been decrypted"

    assert File.read!(source_file) == plaintext
  end

  test "uses configured cipher" do
    plaintext = "this is a secret"
    source_file = @secret_path <> Integer.to_string(System.system_time(:microsecond))

    File.mkdir!(@secret_path)
    File.write!(source_file, plaintext)

    Application.put_env(:secrex, :files, [source_file])
    Application.put_env(:secrex, :cipher, PlaintextCipher)

    capture_io(fn -> Mix.Tasks.Secrex.Encrypt.run([]) end)

    assert_received {:encrypt, key}
    assert key == "1234567890"

    File.rm!(source_file)
    assert File.read!(source_file <> ".enc") == plaintext

    capture_io(fn -> Mix.Tasks.Secrex.Decrypt.run([]) end)

    assert_received {:decrypt, ^key}

    assert File.read!(source_file) == plaintext
  end

  test "handles when no files configured" do
    output = capture_io(fn -> Mix.Tasks.Secrex.Decrypt.run([]) end)

    assert output =~ "Files have been decrypted"
  end

  defp clean_up_directory(_) do
    File.rm_rf!(@secret_path)
    :ok
  end
end

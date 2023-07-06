defmodule Mix.Tasks.SecrexTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup :clean_up_directory

  setup do
    Application.put_env(:secrex, :buckets,
      my_test: [key_file: "test/support/secret-key"],
      my_dev: [key_file: "test/support/.dev.secret-key"]
    )

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
    source_file_test = @secret_path <> Integer.to_string(System.system_time(:microsecond))
    source_file_dev = source_file_test <> "dev"

    File.write!(source_file_dev, plaintext)

    updated_test_bucket = put_files(:my_test, [source_file_test])
    updated_dev_bucket = put_files(:my_dev, [source_file_dev])

    buckets =
      :secrex
      |> Application.get_env(:buckets)
      |> Keyword.put(:my_test, updated_test_bucket)
      |> Keyword.put(:my_dev, updated_dev_bucket)

    Application.put_env(:secrex, :buckets, buckets)

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Encrypt.run(["--bucket", "my_dev"])
      end)

    assert output =~ "Encrypting #{source_file_dev}"
    assert output =~ "Files have been encrypted"

    File.rm!(source_file_dev)
    assert File.read!(source_file_dev <> ".enc") != plaintext

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Decrypt.run(["--bucket", "my_dev"])
      end)

    assert output =~ "Decrypting #{source_file_dev}"
    assert output =~ "Files have been decrypted"

    assert File.read!(source_file_dev) == plaintext

    dev_secret_path = Application.get_env(:secrex, :buckets)[:my_dev][:key_file]
    dev_secret = File.read!(dev_secret_path)
    File.rm!(dev_secret_path)

    assert_raise File.Error, fn -> Mix.Tasks.Secrex.Decrypt.run(["--bucket", "my_dev"]) end

    File.write!(dev_secret_path, dev_secret)

    File.mkdir!(@secret_path)
    File.write!(source_file_test, plaintext)

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Encrypt.run([])
      end)

    assert output =~ "Encrypting #{source_file_test}"
    assert output =~ "Files have been encrypted"

    File.rm!(source_file_test)
    assert File.read!(source_file_test <> ".enc") != plaintext

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Decrypt.run([])
      end)

    assert output =~ "Decrypting #{source_file_test}"
    assert output =~ "Files have been decrypted"

    assert File.read!(source_file_test) == plaintext
  end

  test "uses configured cipher" do
    plaintext = "this is a secret"
    source_file = @secret_path <> Integer.to_string(System.system_time(:microsecond))

    File.mkdir!(@secret_path)
    File.write!(source_file, plaintext)

    updated_bucket = put_files(:my_test, [source_file])

    Application.put_env(:secrex, :buckets, my_test: updated_bucket)
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

  test "checks if decrypted files are in sync with the encrypted ones" do
    plaintext = "this is a secret"
    source_file = @secret_path <> Integer.to_string(System.system_time(:microsecond))

    File.write!(source_file, plaintext)

    updated_bucket = put_files(:my_test, [source_file])

    Application.put_env(:secrex, :buckets, my_test: updated_bucket)

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Encrypt.run(["--bucket", "my_test"])
      end)

    assert output =~ "Encrypting #{source_file}"
    assert output =~ "Files have been encrypted"

    assert Mix.Secrex.secret_files_changed?(:my_test) == false
    assert Mix.Secrex.secret_files_changed?() == false

    File.write!(source_file, plaintext <> "secrets_changed")

    assert Mix.Secrex.secret_files_changed?(:my_test)
    assert Mix.Secrex.secret_files_changed?()

    File.rm!(source_file)
  end

  defp clean_up_directory(_) do
    File.rm_rf!(@secret_path)
    :ok
  end

  defp put_files(bucket, files) do
    Application.get_env(:secrex, :buckets)
    |> Keyword.get(bucket, [])
    |> Keyword.put(:files, files)
  end
end

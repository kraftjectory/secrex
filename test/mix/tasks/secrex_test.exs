defmodule Mix.Tasks.SecrexTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  setup :clean_up_directory

  @secret_path "/tmp/secrex"

  test "encrypts and decrypts secrets to the configured files" do
    plaintext = "this is a secret"
    source_file = @secret_path <> Integer.to_string(System.system_time(:microsecond))

    File.mkdir_p!("/tmp/secrex")
    File.write!(source_file, plaintext)

    Application.put_env(:secrex, :key_file, Path.expand("test/support/secret_key"))
    Application.put_env(:secrex, :files, [source_file])

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Encrypt.run([])
      end)

    assert output =~ "Encrypting #{source_file}"
    assert output =~ "Files have been encrypted"

    File.rm!(source_file)

    output =
      capture_io(fn ->
        Mix.Tasks.Secrex.Decrypt.run([])
      end)

    assert output =~ "Decrypting #{source_file}"
    assert output =~ "Files have been decrypted"

    assert File.read!(source_file) == plaintext
  end

  defp clean_up_directory(_) do
    File.rm_rf!(@secret_path)
    :ok
  end
end

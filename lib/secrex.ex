defmodule Secrex do
  @moduledoc """
  Simple and secure secrets manager fo Elixir projects.

  ## Configuration

  Secrets requires some configurations to work. Add this to your `config.exs`:

      config :secrex,
        key_file: ".secret-key",
        files: ["config/env/prod.secret.exs"]

  ### Supported options

  * `key_file` - path to the key file used for encryption and decryption.
    If not set, you will be prompted to enter a key.
  * `files` - list of files to be encrypted and decrypted.
  * `cipher` - the cipher module to handle secret encryption/decryption.
    Must be an implementation of `Secrex.Cipher`. Defaults to `Secrex.AES`.
  """
end

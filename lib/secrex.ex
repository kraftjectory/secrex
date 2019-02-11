defmodule Secrex do
  @moduledoc """
  Simple and secure secrets manager in Elixir projects.

  ## Configuration

  Secrex reads neccessary configuration from the `:secrex` application. For example, in your application’s configuration (`my_app/config/config.exs`):

      config :secrex,
        key_file: ".secrets_key",
        files: ["config/env/prod.secret.exs"]

  The following is a list of all the supported options:

  * `key_file` - (binary) path to the key file that will be used for encryption and decryption
    if the option is not set, you will be prompted to enter a key later
  * `files` - (list of binaries) list of files that needs to be encrypted and decrypted
  """
end

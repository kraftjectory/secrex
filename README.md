# Secrex

[![Hex Version](https://img.shields.io/hexpm/v/secrex.svg "Hex Version")](https://hex.pm/packages/secrex)

Library that providing Mix tasks for encrypting and decrypting secret files to safely keep them in the repo

## Installation

The package can be installed
by adding `secrex` to our list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:secrex, "~> 0.1.0", runtime: false}
  ]
end
```

## Usage

Secrex requires some configuration in order to work. For example, in `config/config.exs`:

```elixir
config :secrex,
  key_file: ".secrets_key",
  files: ["config/env/prod.secret.exs"]
```

* `key_file` is a path to the key file that will be used for encryption and decryption
  if this is not configured, you will be prompted to enter it later
* `files` is a list of files that needs to be encrypted and decrypted

### Mix tasks

* `mix secrex.encrypt`
* `mix secrex.decrypt`

### Helper functions

For example if we have a `deploy` task, we can prevent deploy if secrets were diverged

```elixir
if Mix.Secrex.secret_files_changed?() do
  Mix.raise(
    "Encrypted files are not matching decrypted\n" <>
    "please run \"mix secrex.decrypt\" to have latest config files"
  )
end
```

## License

This software is licensed under [the ISC license](LICENSE).

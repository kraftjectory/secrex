# Secrex

![CI Status](https://github.com/kraftjectory/secrex/workflows/CI/badge.svg)
[![Hex Version](https://img.shields.io/hexpm/v/secrex.svg "Hex Version")](https://hex.pm/packages/secrex)

Simple and secure secrets manager in Elixir projects

## Installation

The package can be installed
by adding `secrex` to our list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:secrex, "~> 0.3", runtime: false}
  ]
end
```

For usage information see [the documentation](https://hexdocs.pm/secrex).

## Mix tasks

There are two Mix tasks available:

* `mix secrex.encrypt`
* `mix secrex.decrypt`

Secrex requires some configuration in order to work. For example, in `config/config.exs`:

```elixir
config :secrex,
  key_file: ".secret-key",
  files: ["config/env/prod.secret.exs"]
```

* `:key_file` - a path to the key file that will be used for encryption and decryption
  if this is not configured, you will be prompted to enter it later
* `:files` - list of files that needs to be encrypted and decrypted
* `:cipher` - the cipher module to handle secret encryption/decryption.
  Must be an implementation of `Secrex.Cipher`. Defaults to `Secrex.AES`.

## License

This software is licensed under [the ISC license](LICENSE).

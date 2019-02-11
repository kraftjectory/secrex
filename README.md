# Secrex

[![Hex Version](https://img.shields.io/hexpm/v/secrex.svg "Hex Version")](https://hex.pm/packages/secrex)

Simple and secure secrets manager in Elixir projects

## Installation

The package can be installed
by adding `secrex` to our list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:secrex, "~> 0.1", runtime: false}
  ]
end
```

For usage information see [the documentation](https://hexdocs.pm/secrex).

## Mix tasks

* `mix secrex.encrypt`
* `mix secrex.decrypt`

## License

This software is licensed under [the ISC license](LICENSE).

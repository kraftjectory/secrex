defmodule Secrex.MixProject do
  use Mix.Project

  @name "Secrex"
  @version "0.1.0"
  @source_url "https://github.com/ForzaElixir/secrex"

  def project do
    [
      app: :secrex,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: @name,
      description: "Mix tasks to encrypt and decrypt files to safely keep them in the repo",
      docs: [
        main: @name,
        source_ref: "v#{@version}",
        source_url: @source_url
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end

  defp package do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => @source_url}
    ]
  end
end

defmodule Secrex.MixProject do
  use Mix.Project

  @name "Secrex"
  @version "0.4.0"
  @source_url "https://github.com/kraftjectory/secrex"

  def project() do
    [
      app: :secrex,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      package: package(),
      name: @name,
      description: "Simple and secure secrets manager in Elixir projects.",
      docs: [
        main: @name,
        source_ref: "v#{@version}",
        source_url: @source_url,
        extras: ["CHANGELOG.md"]
      ]
    ]
  end

  def application() do
    [extra_applications: [:crypto]]
  end

  defp deps() do
    [
      {:stream_data, "~> 0.4", only: :test},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => @source_url}
    ]
  end
end

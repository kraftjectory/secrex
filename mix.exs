defmodule Secrex.MixProject do
  use Mix.Project

  @name "Secrex"
  @version "0.1.1"
  @source_url "https://github.com/ForzaElixir/secrex"

  def project() do
    [
      app: :secrex,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: @name,
      description: "Simple and secure secrets manager in Elixir projects",
      docs: [
        main: @name,
        source_ref: "v#{@version}",
        source_url: @source_url
      ]
    ]
  end

  def application() do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:stream_data, "~> 0.4", only: :test},
      {:ex_doc, "~> 0.18.0", only: :dev}
    ]
  end

  defp package() do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => @source_url}
    ]
  end
end

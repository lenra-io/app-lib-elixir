defmodule Lenra.MixProject do
  use Mix.Project

  def project do
    [
      app: :lenra_api,
      version: "0.2.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description() do
    """
    The Lenra API and server to create a Lernra app using elixir.
    This contains :
    - The API to contact the /app endpoints
    - Helpers to create the JSON UI
    - Helpers to configure/start the server
    """
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lenra-io/app-lib-elixir"}
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:finch, "~> 0.13.0"}
    ]
  end
end

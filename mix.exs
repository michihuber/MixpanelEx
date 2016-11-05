defmodule Mixpanel.Mixfile do
  use Mix.Project

  def project do
    [app: :mixpanel,
     version: "0.0.3",
     elixir: "~> 1.0",
     deps: deps,

     description: "A client for the Mixpanel HTTP API. See mixpanel.com.",
     package: [
       contributors: ["MSch", "michihuber"],
       licenses: ["MIT"],
       links: %{"Github" => "https://github.com/michihuber/mixpanel_ex"},
     ],
     preferred_cli_env: [
        vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
      ],
    ]
  end

  def application do
    [applications: [:logger, :inets, :ssl],
     env: [token: nil],
     mod: {Mixpanel, []}]
  end

  defp deps do
    [{:exjsx, "~> 3.1"},
     {:exvcr, "~> 0.7", only: :test}]
  end
end

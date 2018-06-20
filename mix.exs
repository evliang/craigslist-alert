defmodule Clex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :clex,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :redix, :sms_blitz],
      mod: {Clex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, ">= 0.0.0 "},
      {:httpoison, ">= 1.2.0", override: true},
      {:floki, ">= 0.0.0"},
      {:sms_blitz, "~> 0.2.0"}
      #{:hound, "~> 1.0"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end

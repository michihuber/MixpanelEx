# MixpanelEx

An Elixir client for the Mixpanel HTTP API. See mixpanel.com.

## Usage
1) Add mixpanel to your deps:

```elixir
{:mixpanel, "0.0.1"}
```

2) Add `:mixpanel` to the list of application dependencies in your `mix.exs`.

```elixir
  def application do
    [applications: [:logger, :mixpanel]]
  end
```

3) Add your mixpanel token to your `config/config.exs` (or similar):

```elixir
config :mixpanel, token: "<YOUR API TOKEN HERE>"
```

4) Track events with `Mixpanel.track`:

```elixir
Mixpanel.track("login", distinct_id: 123)
Mixpanel.track("visited TOS")
```

Or with bulk sending:

```elixir
Mixpanel.track([
  %{event: "login", properties: %{distinct_id: "13793"}},
  %{event: "logout", properties: %{distinct_id: "13793"}}
  ])
```

See the [Mixpanel HTTP API documentation](https://mixpanel.com/help/reference/http#tracking-events) for details.


5) Track users with `Mixpanel.engage`:

```elixir
Mixpanel.engage(%{"$distinct_id" => "123", "$set" => %{"name" => "John Smith"}})
```

Or in bulk:

```elixir
Mixpanel.engage([
  %{"$distinct_id" => "123", "$set" => %{"name" => "John Smith"}},
  %{"$distinct_id" => "345", "$set" => %{"address" => "456 Central Ave"}}
  ])
```

See the [Mixpanel HTTP API documentation](https://mixpanel.com/help/reference/http#people-analytics-updates) for details.

## License
MIT

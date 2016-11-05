defmodule Mixpanel do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    token = Application.get_env(:mixpanel, :token)
    if token == nil do
      raise("Please set :mixpanel, :token in your app environment's config")
    end

    children = [
      worker(Mixpanel.Client, [token]),
    ]
    opts = [strategy: :one_for_one, name: Mixpanel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def track(event, properties, timestamp \\ nil) do
    properties = Mixpanel.Util.add_timestamp(properties, timestamp)
    track([%{event: event, properties: properties}])
  end

  def track(event) when is_binary(event) do
    track(event, [])
  end

  def track(events) when is_list(events) do
    Mixpanel.Client.track(events)
  end

  def engage(event) when is_map(event) do
    engage([event])
  end

  def engage(events) when is_list(events) do
    Mixpanel.Client.engage(events)
  end

  defmodule Util do
    def add_timestamp(properties, nil), do: properties
    def add_timestamp(properties, {mega_secs, secs, _ms}) do
      add_timestamp(properties, mega_secs * 10_000 + secs)
    end
    def add_timestamp(properties, timestamp) when is_integer(timestamp) do
      Dict.put(properties, :time, timestamp)
    end
  end

end

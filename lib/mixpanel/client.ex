require Logger

defmodule Mixpanel.Client do
  @track_endpoint 'https://api.mixpanel.com/track'
  @engage_endpoint 'https://api.mixpanel.com/engage'
  @success_response_body '1'

  use GenServer

  def start_link(token) do
    {:ok, conn} = :inets.start(:httpc, [profile: :mixpanel_http_profile])
    :httpc.set_options([pipeline_timeout: 30000], conn)

    state = %{connection: conn, token: token}
    GenServer.start_link(__MODULE__, state, [name: :mixpanel_client])
  end

  def track(event, properties) do
    GenServer.cast(:mixpanel_client, {:track, event, properties})
  end

  def track(events) when is_list(events) do
    GenServer.cast(:mixpanel_client, {:track, events})
  end

  def engage(event) when is_map(event) do
    GenServer.cast(:mixpanel_client, {:engage, event})
  end

  def engage(events) when is_list(events) do
    GenServer.cast(:mixpanel_client, {:engage, events})
  end

  def handle_cast({:track, event, properties}, state)  do
    properties = Dict.put(properties, :token, state.token)
    {:ok, json} = JSX.encode(event: event, properties: properties)
    bulk_post(json, state.connection, @track_endpoint)
    {:noreply, state}
  end

  def handle_cast({:track, events}, state) when is_list(events) do
    events = Enum.map(events, &put_in(&1, [:properties, :token], state.token))
    {:ok, json} = JSX.encode(events)
    bulk_post(json, state.connection, @track_endpoint)
    {:noreply, state}
  end

  def handle_cast({:engage, event}, state) when is_map(event) do
    events = [Map.put(event, :"$token", state.token)]
    {:ok, json} = JSX.encode(events)
    bulk_post(json, state.connection, @engage_endpoint)
    {:noreply, state}
  end

  def handle_cast({:engage, events}, state) when is_list(events) do
    events = Enum.map(events, &Map.put(&1, :"$token", state.token))
    {:ok, json} = JSX.encode(events)
    bulk_post(json, state.connection, @engage_endpoint)
    {:noreply, state}
  end

  defp bulk_post(json, connection, endpoint) do
    body = String.to_char_list("data=#{ :base64.encode(json) }")
    request = {endpoint, _headers = [], _content_type = 'text/plain', body}
    result = :httpc.request(:post, request, _http_opts=[], _opts=[], connection)
    case result do
      {:ok, {_, _, @success_response_body}} -> :ok
      _ -> Logger.warn("Problem with mixpanel event: " <> inspect(result))
    end
  end
end

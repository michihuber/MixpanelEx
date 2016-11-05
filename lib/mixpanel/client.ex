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

  def track(events) do
    GenServer.cast(:mixpanel_client, {:track, events})
  end

  def engage(events) do
    GenServer.cast(:mixpanel_client, {:engage, events})
  end

  def handle_cast({:track, events}, state) do
    events
    |> Enum.map(&put_in(&1, [:properties, :token], state.token))
    |> bulk_post(@track_endpoint, state)
  end

  def handle_cast({:engage, events}, state) do
    events
    |> Enum.map(&Map.put(&1, :"$token", state.token))
    |> bulk_post(@engage_endpoint, state)
  end

  defp bulk_post(data, endpoint, state) do
    data
    |> encode_body
    |> post(endpoint, state.connection)
    |> log_errors
    {:noreply, state}
  end

  defp encode_body(data) do
    json = JSX.encode!(data)
    String.to_char_list("data=#{ :base64.encode(json) }")
  end

  defp post(body, endpoint, connection) do
    request = {endpoint, _headers = [], _content_type = 'text/plain', body}
    :httpc.request(:post, request, _http_opts=[], _opts=[], connection)
  end

  defp log_errors({:ok, {_, _, @success_response_body}}), do: :ok
  defp log_errors(result) do
    Logger.warn("Problem with mixpanel event: " <> inspect(result))
  end
end

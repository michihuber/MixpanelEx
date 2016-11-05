defmodule MixpanelTest do

  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    :inets.start
    :ok
  end

  test "track an event with no additional properties" do
    use_cassette "mixpanel_track_simple_event" do
      :ok = Mixpanel.track("visited TOS")
    end
  end

  test "track an event with additional properties" do
    use_cassette "mixpanel_track_event_with_properties" do
      :ok = Mixpanel.track("login", distinct_id: 12345)
    end
  end

  test "Bulk track events" do
    use_cassette "mixpanel_bulk_track_events" do
      :ok = Mixpanel.track([
          %{event: "login", properties: %{unique_id: 12345}},
          %{event: "logout", properties: %{unique_id: 12345}}
        ])
    end
  end

  test "Single user profile update" do
    use_cassette "mixpanel_engage_event" do
      :ok = Mixpanel.engage(%{"$distinct_id": "123", "$set": %{name: "John Smith"}})
    end
  end

  test "Bulk user profile update" do
    use_cassette "mixpanel_bulk_engage_events" do
      :ok = Mixpanel.engage([
          %{"$distinct_id": "123", "$set": %{name: "John Smith"}},
          %{"$distinct_id": "345", "$set": %{address: "456 Central Ave"}}
        ])
    end
  end

end

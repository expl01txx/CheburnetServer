defmodule CheburnetServerWeb.Presence do
  use Phoenix.Presence,
    otp_app: :cheburnet_server,
    pubsub_server: CheburnetServer.PubSub
end

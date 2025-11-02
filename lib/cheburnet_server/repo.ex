defmodule CheburnetServer.Repo do
  use Ecto.Repo,
    otp_app: :cheburnet_server,
    adapter: Ecto.Adapters.Postgres
end

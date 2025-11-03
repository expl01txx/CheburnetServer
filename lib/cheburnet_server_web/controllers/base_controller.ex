defmodule CheburnetServerWeb.BaseController do
  use CheburnetServerWeb, :controller
  def ping(conn, _params) do
    conn
      |> json(%{ok: "pong"})
  end
end

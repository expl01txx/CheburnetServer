defmodule CheburnetServerWeb.BaseController do
  use CheburnetServerWeb, :controller
  alias CheburnetServer.Accounts.Accounts

  def ping(conn, _params) do
    conn
      |> json(%{ok: "pong"})
  end

  def get_user_id(conn, %{"login" => login}) do
    case Accounts.get_user_id_by_login(login) do
      {:ok, user_id} ->
        json(conn, %{id: user_id})
      {:error, _} ->
        json(conn, %{error: "user not found"})
    end
  end

  def get_user_id(conn, _params) do
    conn
      |> put_status(:bad_request)
      |> json(%{error: "login required"})
  end
end

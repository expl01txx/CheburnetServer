defmodule CheburnetServerWeb.BaseController do
  use CheburnetServerWeb, :controller
  alias CheburnetServer.Accounts.Accounts
  alias CheburnetServer.Cache

  def ping(conn, _params) do
    conn
    |> json(%{ok: "pong"})
  end

  def get_user_id(conn, %{"login" => login}) do
    with {:ok, nil} <- Cache.get_user_cache(login),
         {:ok, user_id} <- Accounts.get_user_id_by_login(login) do
      CheburnetServer.Cache.put_user_cache(login, user_id)
      json(conn, %{id: user_id})
    else
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

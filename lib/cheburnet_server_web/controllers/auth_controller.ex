defmodule CheburnetServerWeb.AuthController do
  use CheburnetServerWeb, :controller

  alias CheburnetServer.Accounts.Accounts
  alias CheburnetServer.Auth.Jwt

  def register(conn, %{"login" => login, "password" => password}) do
    case Accounts.register_user(%{login: login, password: password}) do
      {:ok, user} ->
        token = Jwt.token_for_user(user)
        conn
          |> put_status(:created)
          |> json(%{token: token, user: %{id: user.id, login: user.login}})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
          |> put_status(:bad_request)
          |> json(%{errors: translate_errors(changeset)})
    end
  end

  def register(conn, _params) do
    conn
      |> put_status(:bad_request)
      |> json(%{error: "login and password required"})
  end

  def login(conn, %{"login" => login, "password" => password}) do
    case Accounts.authenticate_by_login_password(login, password) do
      {:ok, user} ->
        token = Jwt.token_for_user(user)
        conn
          |> json(%{token: token, user: %{id: user.id, login: user.login}})
      {:error, :invalid_credentials} ->
        conn
          |> put_status(:unauthorized)
          |> json(%{error: "invalid credentials"})
    end
  end

  def login(conn, _params) do
    conn
      |> put_status(:bad_request)
      |> json(%{error: "login and password required"})
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{#{k}}", to_string(v)) end)
    end)
  end
end

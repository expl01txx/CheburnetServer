defmodule CheburnetServer.Accounts.Accounts do
  alias CheburnetServer.Repo
  alias CheburnetServer.Accounts.User
  import Ecto.Query, only: [from: 2]

  def register_user(attrs) do
    %User{}
      |> User.registration_changeset(attrs)
      |> Repo.insert()
  end

  def get_user_by_login(login) when is_binary(login) do
    Repo.get_by(User, login: login)
  end

  def get_user_id_by_login(login) do
    case get_user_by_login(login) do
      nil ->
        {:error, :invalid_credentials}
      %User{} = user ->
        {:ok, user.id}
    end
  end

  def authenticate_by_login_password(login, password) do
    case get_user_by_login(login) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      %User{} = user ->
        if Argon2.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end

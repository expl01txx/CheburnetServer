defmodule CheburnetServer.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :login, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :role, :string, default: "user"
    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
      |> cast(attrs, [:login, :password, :role])
      |> validate_required([:login, :password])
      |> validate_length(:login, min: 3)
      |> validate_length(:password, min: 6)
      |> unique_constraint(:login)
      |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        hashed = Argon2.hash_pwd_salt(password)
        changeset
          |> put_change(:hashed_password, hashed)
          |> delete_change(:password)
    end
  end
end

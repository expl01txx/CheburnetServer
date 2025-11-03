defmodule CheburnetServer.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :login, :string, null: false
      add :hashed_password, :string, null: false
      add :role, :string, default: "user"
      timestamps()
    end

    create unique_index(:users, [:login])
  end
end

defmodule CheburnetServer.Repo.Migrations.Messages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :user_id, :integer, null: false
      add :message, :string, null: false
      timestamps()
    end
  end
end

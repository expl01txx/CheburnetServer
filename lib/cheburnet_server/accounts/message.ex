defmodule CheburnetServer.Accounts.Message do
  use Ecto.Schema

  schema "messages" do
    field :user_id, :integer
    field :message, :string
    timestamps()
  end
end

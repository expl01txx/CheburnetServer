defmodule CheburnetServere.Rooms do
  def resolve_username(claims) do
    case claims["login"] do
      nil -> {:error, "login not found in token"}
      username -> {:ok, username}
    end
  end
end

defmodule CheburnetServere.Rooms do
  def resolve_username(claims) do
    case claims["login"] do
      nil -> {:error, "login not found in token"}
      username -> {:ok, username}
    end
  end

  def verify_id(id, claims) do
    if claims["sub"] == id do
      {:ok}
    else
      {:error, "token id and user id are not equal"}
    end
  end
end

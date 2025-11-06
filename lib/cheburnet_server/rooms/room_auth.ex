defmodule CheburnetServer.Rooms.RoomAuth do
  alias CheburnetServer.Auth.Jwt

  def verify_token(token) do
    case Jwt.verify_and_validate(token) do
      {:ok, claims} -> {:ok, claims}
      {:error, _} -> {:error, "invalid token"}
    end
  end
end

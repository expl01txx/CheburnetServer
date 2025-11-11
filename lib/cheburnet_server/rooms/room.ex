defmodule CheburnetServer.Rooms do
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

  def validate_user_id(user_id, self_id) do
    cond do
      !is_integer(user_id) ->
        {:error, :invalid_user_id}

      user_id == self_id ->
        {:error, :self_message}

      true ->
        {:ok, user_id}
    end
  end
end

defmodule CheburnetServerWeb.RoomChannel do
  use CheburnetServerWeb, :channel
  alias CheburnetServere.Rooms
  alias CheburnetServer.Rooms.RoomAuth

  @impl true
  def join("user:" <> id, payload, socket) do
    with {:ok, decoded} <- Jason.decode(payload),
         {:ok, token} <- Map.fetch(decoded, "token"),
         {:ok, claims} <- RoomAuth.verify_token(token),
         {:ok, username} <- Rooms.resolve_username(claims),
         {:ok} <- Rooms.verify_id(id, claims) do
      socket = assign(socket, :username, username)
      socket = assign(socket, :user_id, id)
      {:ok, socket}
    else
      :error -> {:error, %{reason: "token not provided"}}
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> {:error, %{reason: "bad request"}}
    end
  end

  @impl true
  def handle_in("new_msg", payload, socket) do
    with {:ok, decoded} <- Jason.decode(payload),
      body when is_binary(body) <- decoded["body"] do
        CheburnetServerWeb.Endpoint.broadcast("user:#{decoded["user_id"]}", "new_msg", %{body: body, user_id: socket.assigns[:user_id]})
        {:noreply, socket}
    else
      _ -> {:reply, {:error, %{reason: "invalid message"}}, socket}
    end
  end

  @impl true
  def terminate(reason, _) do
    IO.puts("Left room: #{inspect(reason)}")
    :ok
  end
end

defmodule CheburnetServerWeb.RoomChannel do
  use CheburnetServerWeb, :channel
  alias CheburnetServere.Rooms
  alias CheburnetServer.Rooms.RoomAuth

  @impl true
  def join("room:base", payload, socket) do
    with {:ok, decoded} <- Jason.decode(payload),
         {:ok, token} <- Map.fetch(decoded, "token"),
         {:ok, claims} <- RoomAuth.verify_token(token),
         {:ok, username} <- Rooms.resolve_username(claims) do

      socket = assign(socket, :username, username)
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
      broadcast!(socket, "new_msg", %{
        username: socket.assigns.username,
        body: body
      })

      {:noreply, socket}
    else
      _ -> {:reply, {:error, %{reason: "invalid message"}}, socket}
    end
  end

  @impl true
  def terminate(reason, socket) do
    IO.puts("Left room: #{inspect(reason)}")
    :ok
  end

  defp authorized?(_payload) do
    true
  end
end

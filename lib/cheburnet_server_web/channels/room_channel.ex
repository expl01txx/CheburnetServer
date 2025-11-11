defmodule CheburnetServerWeb.RoomChannel do
  use CheburnetServerWeb, :channel
  alias Ecto.UUID
  alias CheburnetServere.Rooms
  alias CheburnetServer.Rooms.RoomAuth
  alias CheburnetServer.Messages
  alias CheburnetServerWeb.Presence

  @impl true
  def join("user:" <> id, payload, socket) do
    with {:ok, token} <- Map.fetch(payload, "token"),
         {:ok, claims} <- RoomAuth.verify_token(token),
         {:ok, username} <- Rooms.resolve_username(claims),
         {:ok} <- Rooms.verify_id(id, claims) do
      socket = assign(socket, :username, username)
      socket = assign(socket, :user_id, id)
      send(self(), :after_join)
      {:ok, socket}
    else
      :error -> {:error, %{reason: "token not provided"}}
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> {:error, %{reason: "bad request"}}
    end
  end

  @impl true
  def handle_in("new_msg", payload, socket) do
    with body when is_binary(body) <- payload["body"],
         user_id <- payload["user_id"] do
      topic = "user:#{user_id}"

      if Presence.list(topic) |> map_size() > 0 do
        CheburnetServerWeb.Endpoint.broadcast(topic, "new_msg", %{
          body: body,
          user_id: socket.assigns[:user_id]
        })

        {:noreply, socket}
      else
        Messages.store_message(user_id, UUID.generate(), %{
          msg: body,
          user_id: socket.assigns[:user_id]
        })

        {:reply, {:ok, %{info: "User offline, message stored"}}, socket}
      end
    else
      _ -> {:reply, {:error, %{reason: "invalid message"}}, socket}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user_id, %{
      online_at: System.system_time(:second)
    })

    stored_messages = CheburnetServer.Messages.get_messages(socket.assigns.user_id)

    Enum.each(stored_messages, fn msg ->
      push(socket, "new_msg", msg)
    end)

    {:noreply, socket}
  end

  @impl true
  def terminate(reason, _) do
    IO.puts("Left room: #{inspect(reason)}")
    :ok
  end
end

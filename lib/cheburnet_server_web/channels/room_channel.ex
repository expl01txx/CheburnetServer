defmodule CheburnetServerWeb.RoomChannel do
  use CheburnetServerWeb, :channel
  alias Ecto.UUID
  alias CheburnetServer.Rooms
  alias CheburnetServer.Rooms.RoomAuth
  alias CheburnetServer.Messages
  alias CheburnetServerWeb.Presence

  @impl true
  def join("user:" <> id, payload, socket) do
    with {:ok, token} <- Map.fetch(payload, "token"),
         {:ok, claims} <- RoomAuth.verify_token(token),
         {:ok, username} <- Rooms.resolve_username(claims),
         {:ok} <- Rooms.verify_id(id, claims),
         {user_id, _} <- Integer.parse(id, 10) do
      socket = assign(socket, :username, username)
      socket = assign(socket, :user_id, user_id)
      send(self(), :after_join)
      {:ok, socket}
    else
      :error -> {:error, %{reason: "bad request"}}
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> {:error, %{reason: "bad request"}}
    end
  end

  @impl true
  def handle_in("new_msg", payload, socket) do
    with body when is_binary(body) <- payload["body"],
         user_id <- payload["user_id"],
         {:ok, user_id} <- Rooms.validate_user_id(user_id, socket.assigns[:user_id]) do
      topic = "user:#{user_id}"

      if Presence.list(topic) |> map_size() > 0 do
        CheburnetServerWeb.Endpoint.broadcast(topic, "new_msg", %{
          body: body,
          user_id: socket.assigns[:user_id]
        })

        {:noreply, socket}
      else
        Messages.store_message(user_id, UUID.generate(), %{
          body: body,
          user_id: socket.assigns[:user_id]
        })

        {:reply, {:ok, %{info: "User offline, message stored"}}, socket}
      end
    else
      {:error, :not_binary} ->
        {:reply, {:error, %{reason: "message body must be a string"}}, socket}

      {:error, :invalid_user_id} ->
        {:reply, {:error, %{reason: "user_id must be an integer"}}, socket}

      {:error, :self_message} ->
        {:reply, {:error, %{reason: "cannot send message to yourself"}}, socket}

      _ ->
        {:reply, {:error, %{reason: "invalid message"}}, socket}
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
  def terminate(_, _) do
    :ok
  end
end

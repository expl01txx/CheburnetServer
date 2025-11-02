defmodule CheburnetServerWeb.RoomChannel do
  use CheburnetServerWeb, :channel

  @impl true
  def join("room:" <> room_id, payload, socket) do
    IO.puts("Joined room: #{room_id}")

    if authorized?(payload) do
      socket = assign(socket, :room_id, room_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    room_id = socket.assigns[:room_id]
    IO.puts("Received ping in room: #{room_id}")
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("auth", payload, socket) do
    socket = assign(socket, :username, payload["username"])
    IO.puts("#{payload["username"]} authorizated")
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_msg", payload, socket) do
    if (Map.has_key?(socket.assigns, :username)) do
      IO.puts("#{socket.assigns.username} send #{payload["body"]}")
      broadcast(socket, "new_msg", %{
        body: payload["body"]
      })
    end
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, socket) do
    room_id = socket.assigns[:room_id]
    IO.puts("Left room: #{room_id} - Reason: #{inspect(reason)}")
    :ok
  end

  defp authorized?(_payload) do
    true
  end
end

defmodule CheburnetServer.Messages do
  @ttl 60 * 60 * 24 * 3
  @redis :redis

  def store_message(user_id, msg_id, payload) do
    key = "message:#{user_id}:#{msg_id}"
    value = Jason.encode!(payload)

    Redix.command!(@redis, ["SETEX", key, @ttl, value])
  end

  def get_messages(user_id) do
    {:ok, keys} = Redix.command(@redis, ["KEYS", "message:#{user_id}:*"])

    keys
    |> Enum.map(fn key ->
      case Redix.pipeline(@redis, [["GET", key], ["DEL", key]]) do
        {:ok, [val, _]} ->
          case val do
            nil -> nil
            msg -> Jason.decode!(msg)
          end
        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end
end

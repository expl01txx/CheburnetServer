defmodule CheburnetServer.Cache do
  @cache :local_cache

  def put_user_cache(login, data) do
    Cachex.put(@cache, "user:#{login}", data, ttl: :timer.minutes(10))
  end

  def get_user_cache(login) do
    Cachex.get(@cache, "user:#{login}")
  end
end

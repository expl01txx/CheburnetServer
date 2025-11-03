defmodule CheburnetServer.Auth.Jwt do
  use Joken.Config
  alias Joken.Signer

  @ttl (60 * 60 * 24) * 7 #7 days token lifetime

  def token_for_user(user) do
    claims = %{
      "sub" => to_string(user.id),
      "login" => user.login,
      "role" => user.role,
      "exp" => Joken.current_time() + @ttl
    }

    secret = Application.get_env(:cheburnet_server, CheburnetServer.Auth)[:jwt_secret]
    mysigner = Signer.create("HS256", secret)
    {:ok, token, _claims} = Joken.encode_and_sign(claims, mysigner)
    token
  end
end

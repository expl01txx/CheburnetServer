defmodule CheburnetServerWeb.PageController do
  use CheburnetServerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

## CheburnetServer - provides backend for auth, messaging and API for Cheburnet messenger project.

### Dependencies:
* postgres 14
* erlang-otp 28
* elixir 1.92.2

### To start your server (dev mode):
#### Using host:
* Install dependencies
* Configure postgres
* Change `config/dev.exs` config to match postgres configuration
* run `mix setup`
* start server using `mix phx.server`

#### Using docker:
* Run `./run_dev.sh` to build docker image, install and setup dependencies and start server in dev mode


### Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix

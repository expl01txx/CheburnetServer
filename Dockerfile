FROM elixir:1.19.2-otp-28 AS build

RUN apt-get update && apt-get install -y build-essential git

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile
RUN mix ecto.migrate

COPY . .

EXPOSE 4000
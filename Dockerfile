FROM elixir:1.19.2-otp-28 AS build

RUN apt-get update && apt-get install -y build-essential git

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

EXPOSE 4000
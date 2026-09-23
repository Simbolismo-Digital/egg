FROM hexpm/elixir:1.20.2-erlang-29.0.3-debian-bookworm-20250630

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git inotify-tools && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app
CMD ["bash"]
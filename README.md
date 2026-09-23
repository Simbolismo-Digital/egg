# Teaching Elixir

`My IDE`: VSCODE with vanilla Elixir language server.

Dependencies:

* [docker](./Dockerfile)
* [docker compose](./docker-compose.yml)
* [asdf](.tool-versions)

> **TODO (author):** improve deps cover [explain/install].

## Setup `asdf`.

### Build erlang deps

```
sudo apt-get install -y build-essential autoconf m4 libncurses-dev \
  libssl-dev libwxgtk3.2-dev libgl1-mesa-dev libglu1-mesa-dev \
  libpng-dev libsctp-dev unixodbc-dev xsltproc fop
```

### Install `asdf plugins`.

```sh
asdf plugin add erlang
asdf plugin add elixir
asdf install
```

### Test installation

```sh
`egg$` erl -eval 'io:format("~s~n", [erlang:system_info(otp_release)]), halt().' -noshell
29

`egg$` elixir -v
Erlang/OTP 29 [erts-17.0.3] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Elixir 1.20.2 (compiled with Erlang/OTP 29)
```

## Start a new project

Install the Phoenix generator:

```sh
mix archive.install hex phx_new
```

Generate the app in the current directory:

```sh
mix phx.new . --app app
```

- When asked to continue in a non-empty directory, answer `Y`.
- When asked to overwrite `README.md`, answer `n` to keep this one.

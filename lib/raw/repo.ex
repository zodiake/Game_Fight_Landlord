defmodule Raw.Repo do
  use Ecto.Repo,
    otp_app: :raw,
    adapter: Ecto.Adapters.Postgres
end

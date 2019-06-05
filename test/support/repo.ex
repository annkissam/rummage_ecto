defmodule Rummage.Ecto.Repo do
  use Ecto.Repo, otp_app: :rummage_ecto, adapter: Ecto.Adapters.Postgres
end

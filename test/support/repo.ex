defmodule Rummage.Ecto.Repo do
  use Ecto.Repo, otp_app: :rummage_ecto, adapter: Sqlite.Ecto2
end

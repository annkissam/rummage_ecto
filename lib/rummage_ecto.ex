defmodule Rummage.Ecto do
  @moduledoc ~S"""
  Rummage.Ecto is a simple framework that can be used to alter Ecto queries with
  Search, Sort and Paginate operations.

  It accomplishes the above operations by using `Hooks`, which are modules that
  implement `Rumamge.Ecto.Hook` behavior. Each operation: Search, Sort and Paginate
  have their hooks defined in Rummage. By doing this, we have made rummage completely
  configurable. For example, if you don't like one of the implementations of Rummage,
  but like the other two, you can configure Rummage to not use it.

  If you want to check a sample application that uses Rummage, please check
  [this link](https://github.com/Excipients/rummage_ecto).
  """

  alias Rummage.Ecto.Config

  def rummage(query, rummage) when is_nil(rummage) or rummage == %{} do
    rummage = %{"search" => %{},
      "sort"=> [],
      "paginate" => %{"per_page" => Config.default_per_page, "page" => "1"}
    }

    query = query
    |> Config.default_paginate.run(rummage)

    {query, rummage}
  end

  def rummage(query, rummage) do
    query = query
      |> Config.default_search.run(rummage)
      |> Config.default_sort.run(rummage)
      |> Config.default_paginate.run(rummage)

    {query, rummage}
  end

  def per_page do
    Config.default_per_page
  end
end

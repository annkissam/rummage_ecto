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

  defmacro __using__(opts) do
    quote do
      def rummage(query, rummage) when is_nil(rummage) or rummage == %{} do
        rummage = %{"search" => %{},
          "sort"=> [],
          "paginate" => %{"per_page" => per_page(), "page" => "1"}
        }

        query = query
        |> paginate_hook_call(rummage)

        {query, rummage}
      end

      def rummage(query, rummage) do
        query = query
          |> search_hook_call(rummage)
          |> sort_hook_call(rummage)
          |> paginate_hook_call(rummage)

        {query, rummage}
      end

      defp search_hook_call(query, rummage) do
        unquote(opts[:search_hook] || Config.default_search).run(query, rummage)
      end

      defp sort_hook_call(query, rummage) do
        unquote(opts[:sort_hook] || Config.default_sort).run(query, rummage)
      end

      defp paginate_hook_call(query, rummage) do
        unquote(opts[:paginate_hook] || Config.default_paginate).run(query, rummage, unquote(opts[:repo]))
      end

      defp per_page do
        unquote(Integer.to_string(opts[:per_page]) || Config.default_per_page)
      end
    end
  end
end

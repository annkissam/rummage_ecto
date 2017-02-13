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

        query
        |> paginate_hook_call(rummage)
      end

      def rummage(query, rummage) do
        query
        |> search_hook_call(rummage)
        |> sort_hook_call(rummage)
        |> paginate_hook_call(rummage)
      end

      def search_hook_call(query, rummage) do
        unquote(opts[:search_hook] || Config.default_search).run(query, rummage)
      end

      def sort_hook_call(query, rummage) do
        unquote(opts[:sort_hook] || Config.default_sort).run(query, rummage)
      end

      def paginate_hook_call(query, rummage) do
        case unquote(opts[:paginate_hook]) do
          nil ->
            rummage = before_paginate(query, rummage)
            {unquote(Config.default_paginate).run(query, rummage), rummage}
          _ ->
            {unquote(opts[:paginate_hook]).run(query, rummage), rummage}
      end

      def per_page do
        unquote(Integer.to_string(opts[:per_page]) || Config.default_per_page)
      end

      def before_paginate(query, rummage) do
        paginate_params = Map.get(rummage, "paginate")

        case paginate_params do
          nil -> {query, rummage}
          _ ->
            total_count = case unquote(opts[:repo]) do
              nil -> raise "No Repo provided for Rummage struct"
              _ -> query
              |> select([b], count(b.id))
              |> unquote(opts[:repo]).one
            end

            per_page = paginate_params
              |> Map.get("per_page", per_page)
              |> String.to_integer

            page = paginate_params
              |> Map.get("page", "1")
              |> String.to_integer

            per_page = if per_page < 1, do: 1, else: per_page

            max_page = (total_count / per_page)
              |> Float.ceil
              |> round
            end

            page = cond do
              page < 1 ->  1
              max_page && page > max_page -> max_page
              true -> page
            end

            paginate_params = paginate_params
            |> Map.put("page", Integer.to_string(page))
            |> Map.put("page", Integer.to_string(per_page))
            |> Map.put("total_count", Integer.to_string(total_count))
            |> Map.put("max_page", Integer.to_string(max_page))

            Map.put("paginate", paginate_params)
        end
      end
    end
  end
end

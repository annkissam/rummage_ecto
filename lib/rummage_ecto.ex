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
  [this link](https://github.com/Excipients/rummage_phoenix_example).


  """

  alias Rummage.Ecto.Config

  defmacro __using__(opts) do
    quote do
      import Ecto.Query

      @spec rummage(Ecto.Query.t, map) :: {Ecto.Query.t, map}
      def rummage(queryable, rummage) when is_nil(rummage) or rummage == %{} do
        params = %{"search" => %{},
          "sort"=> [],
          "paginate" => %{"per_page" => default_per_page(), "page" => "1"},
        }

        rummage = before_paginate(queryable, params)

        queryable = queryable
          |> paginate_hook_call(rummage)

        {queryable, rummage}
      end

      def rummage(queryable, rummage) do
        searched_queryable = queryable
          |> search_hook_call(rummage)

        rummage = before_paginate(searched_queryable, rummage)

        rummaged_queryable = searched_queryable
          |> sort_hook_call(rummage)
          |> paginate_hook_call(rummage)

        {rummaged_queryable, rummage}
      end

      def default_per_page do
        unquote(Integer.to_string(opts[:per_page] || Config.default_per_page))
      end

      defp search_hook_call(queryable, rummage) do
        unquote(opts[:search_hook] || Config.default_search).run(queryable, rummage)
      end

      defp sort_hook_call(queryable, rummage) do
        unquote(opts[:sort_hook] || Config.default_sort).run(queryable, rummage)
      end

      defp paginate_hook_call(queryable, rummage) do
        unquote(opts[:paginate_hook] || Config.default_paginate).run(queryable, rummage)
      end

      defp before_paginate(queryable, rummage) do
        paginate_params = Map.get(rummage, "paginate")

        case paginate_params do
          nil -> rummage
          _ ->
            total_count = get_total_count(queryable)

            {page, per_page} = parse_page_and_per_page(paginate_params)

            per_page = if per_page < 1, do: 1, else: per_page

            max_page_fl = total_count / per_page
            max_page = max_page_fl
              |> Float.ceil
              |> round

            page = cond do
              page < 1 ->  1
              max_page > 0 && page > max_page -> max_page
              true -> page
            end

            paginate_params = paginate_params
              |> Map.put("page", Integer.to_string(page))
              |> Map.put("per_page", Integer.to_string(per_page))
              |> Map.put("total_count", Integer.to_string(total_count))
              |> Map.put("max_page", Integer.to_string(max_page))

            Map.put(rummage, "paginate", paginate_params)
        end
      end

      defp get_total_count(queryable) do
        repo = get_repo()

        queryable = queryable
          |> select([b], count(b.id))

        apply(repo, :one, [queryable])
      end

      defp get_repo do
        unquote(opts[:repo]) ||
          Config.default_repo ||
          make_repo_name_from_topmost_namespace
      end

      defp make_repo_name_from_topmost_namespace do
        "#{__MODULE__}"
        |> String.split(".")
        |> Enum.at(1)
        |> (& "Elixir." <> &1 <> ".Repo").()
        |> String.to_atom
      end

      defp parse_page_and_per_page(paginate_params) do
        per_page = paginate_params
          |> Map.get("per_page", default_per_page())
          |> String.to_integer

        page = paginate_params
          |> Map.get("page", "1")
          |> String.to_integer

        {page, per_page}
      end
    end
  end
end

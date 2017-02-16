# Rummage.Ecto

**If you're looking for `Phoenix` support, you might wanna check `Rummage.Phoenix` instead by clicking
[here](https://github.com/Excipients/rummage_phoenix)**

`Rummage.Ecto` is a simple framework that can be used to alter `Ecto` queries with Search, Sort and Paginate operations.

It accomplishes the above operations by using `Hooks`, which are modules that implement `Rumamge.Ecto.Hook` behavior.
Each operation: `Search`, `Sort` and `Paginate` have their hooks defined in `Rummage`. By doing this, `Rummage` is completely
configurable. For example, if you don't like one of the implementations of `Rummage`, but like the other two,
 you can configure `Rummage` to not use it.


**NOTE: `Rummage` is not like `Ransack`, and doesn't intend to be either. It doesn't add functions based on search params.
If you'd like to have that for a model, you can always configure `Rummage` to use your `Search` module for that model. This
is why Rummage has been made configurable.**

## Installation

This package is [available in Hex](https://hexdocs.pm/rummage_ecto/api-reference.html), and can be installed as:

  - Add `rummage_ecto` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rummage_ecto, "~> 0.6.0"}]
    end
    ```


## Configuration (Optional, If not configuration is provided `Rummage` will use default hooks)

  - If you wanna override any of the `Rummage` default hooks,
    add `rummage_ecto` config to your list of configs in `dev.exs`:

    ```elixir
    config :rummage_ecto,
      Rummage.Ecto,
      default_search: MyApp.SearchModule
    ```

  - Other config options are: `default_sort`, `default_paginate`, `default_per_page`

  - `Rumamge.Ectp` can be configured globally with a `default_per_page` value (which can be overriden for a model).
    This is **NOT** the preferred way to set `per_page` as it might lead to conflicts. It is recommended to
    do it per model as show below in the [Initial Setup](#initial-setup) section. If you wanna set per_page
    for all the models, add it to `model` function in `web.ex`


### Initial Setup

  - Use `Rummage.Ecto` in the models/ecto structs:

  ```elixir
  defmodule MyApp.Product do
    use MyApp.Web, :model
    use Rummage.Ecto, repo: MyApp.Repo, per_page: 5 # <-- You don't have to pass per_page if you have set it in the config.exs, but this way is preferred over setting it up in config file.

    # More code below....
  end
  ```

### Usage

  - Setting up the application above will allow us to do the following:

  ```elixir
  rummage = %{
    "search" => %{"name" => "value1", "category" => "value2"},
    "sort" => "name.desc",
    "paginate" => %{"per_page" => "5", "page" => "1"}
  }

  {query, rummage} = query
    |> Product.rummage(rummage)

  products = query
  |> Product.another_operation # <-- Since `Rummage` is Ecto, we can pipe the result query into another query operation.
  |> Repo.all
  ```

  - Rummage responds to `params` with keys: `search`, `sort` and/or `paginate`. It doesn't need to have all the keys, or any keys for that matter.
    If invalid keys are passed, they won't alter any operations in rummage. Here's an example of `Rummage` params:

  ```elixir
  %{
      "search" => %{"name" => "value1", "category" => "value2"},
      "sort" => "name.desc",
      "paginate" => %{"per_page" => "5", "page" => "1"}
    }
  ```



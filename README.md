# Rummage.Ecto

[![Build Status](https://travis-ci.org/Excipients/rummage_ecto.svg?branch=master)](https://travis-ci.org/Excipients/rummage_ecto)
[![Coverage Status](https://coveralls.io/repos/github/Excipients/rummage_ecto/badge.svg?branch=master)](https://coveralls.io/github/Excipients/rummage_ecto?branch=master)
[![Hex Version](http://img.shields.io/hexpm/v/rummage_ecto.svg?style=flat)](https://hex.pm/packages/rummage_ecto)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/rummage_ecto.svg)](https://hex.pm/packages/rummage_ecto)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/rummage_ecto)
[![docs](https://inch-ci.org/github/Excipients/rummage_ecto.svg)](http://inch-ci.org/github/Excipients/rummage_ecto)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Excipients/rummage_ecto/master/LICENSE)

**If you're looking for full `Phoenix` support, `Rummage.Phoenix` uses `Rumamge.Ecto` and adds `HTML` and `Controller` support
to it. You can check `Rummage.Phoenix` out by clicking [here](https://github.com/Excipients/rummage_phoenix)**

**Please refer for [CHANGELOG](CHANGELOG.md) for version specific changes**

`Rummage.Ecto` is a framework that can be used to alter `Ecto` queries with Search, Sort and Paginate operations.

It accomplishes the above operations by using `Hooks`, which are modules that implement `Rumamge.Ecto.Hook` behavior.
Each operation: `Search`, `Sort` and `Paginate` have their hooks defined in `Rummage`. By doing this, `Rummage` is completely
configurable.

For example, if you don't like one of the implementations of `Rummage`, but like the other two, you can configure `Rummage` to not use it.

**NOTE: `Rummage` is not like `Ransack`, and doesn't intend to be. It doesn't define functions based on search params.
If you'd like to have that for a model, you can always configure `Rummage` to use your `Search` module for that model. This
is why Rummage has been made configurable.**

## Installation

This package is [available in Hex](https://hexdocs.pm/rummage_ecto/), and can be installed as:

  - Add `rummage_ecto` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rummage_ecto, "~> 1.0.0"}]
    end
    ```


## Configuration (Optional, If no configuration is provided `Rummage` will use default hooks)

  - If you want to override any of the `Rummage` default hooks,
    add `rummage_ecto` config to your list of configs in `dev.exs`:

    ```elixir
    config :rummage_ecto,
      Rummage.Ecto,
      default_search: MyApp.SearchModule
    ```

  - Other config options are: `default_repo`, `default_sort`, `default_paginate`, `default_per_page`

  - `Rumamge.Ecto` can be configured globally with a `default_per_page` value (which can be overridden for a model).
    This is **NOT** the preferred way to set `per_page` as it might lead to conflicts. It is recommended to
    do it per model as show below in the [Initial Setup](#initial-setup) section, as it gives the developer more
    flexibility. If you want to set per_page for all the models, add it to `model` function in `web.ex`.


## Usage

`Rummage.Ecto` comes with a lot of powerful features which are available right away, without writing a bunch of code.
Below are the ways `Rummage.Ecto` can be used:

### Basic Usage:

  - Add the `Repo` of your app and the desired `per_page` (if using Rumamge's Pagination) to the `rummage_ecto` configuration in `config.exs`:

  ```elixir
  config :rummage_ecto, Rummage.Ecto,
    default_repo: MyApp.Repo,
    default_per_page: 10
  ```

  - Use `Rummage.Ecto` in the models or ecto_structs:

  ```elixir
  defmodule MyApp.Product do
    use MyApp.Web, :model
    use Rummage.Ecto

    # More code below....
  end
  ```

  - And you should be able to use `Rummage.Ecto` with `Product` model.

### Advanced Usage:

  - Coming soon...


### Usage ( not after 0.6.0 )

  - Setting up the application above will allow us to do the following:

  ```elixir
  rummage = %{
    "search" => %{"name" => "value1", "category" => "value2"},
    "sort" => "name.desc",
    "paginate" => %{"per_page" => "5", "page" => "1"}
  }

  {queryable, rummage} = queryable
    |> Product.rummage(rummage)

  products = queryable
  |> Product.another_operation # <-- Since `Rummage` is Ecto, we can pipe the result queryable into another queryable operation.
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



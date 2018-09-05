# Rummage.Ecto

<img src="src/rummage_logo.png" alt="https://hexdocs.pm/rummage_ecto/Rummage.Ecto.html" width="150" height="150">

[![Build Status](https://travis-ci.org/annkissam/rummage_ecto.svg?branch=master)](https://travis-ci.org/annkissam/rummage_ecto)
[![Coverage Status](https://coveralls.io/repos/github/annkissam/rummage_ecto/badge.svg?branch=master)](https://coveralls.io/github/annkissam/rummage_ecto?branch=master)
[![Hex Version](http://img.shields.io/hexpm/v/rummage_ecto.svg?style=flat)](https://hex.pm/packages/rummage_ecto)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/rummage_ecto.svg)](https://hex.pm/packages/rummage_ecto)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/rummage_ecto)
[![docs](https://inch-ci.org/github/annkissam/rummage_ecto.svg)](http://inch-ci.org/github/annkissam/rummage_ecto)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/annkissam/rummage_ecto/master/LICENSE)

**If you're looking for full `Phoenix` support, `Rummage.Phoenix` uses `Rummage.Ecto` and adds `HTML` and `Controller` support
to it. You can check `Rummage.Phoenix` out by clicking [here](https://github.com/annkissam/rummage_phoenix)**

**Please refer for [CHANGELOG](CHANGELOG.md) for version specific changes**

`Rummage.Ecto` is a light weight, but powerful framework that can be used to alter `Ecto` queries with Search, Sort and Paginate operations.

It accomplishes the above operations by using `Hooks`, which are modules that implement `Rummage.Ecto.Hook` behavior.
Each operation: `Search`, `Sort` and `Paginate` have their hooks defined in `Rummage`. By doing this, `Rummage` is completely
configurable.

For example, if you don't like one of the hooks of `Rummage`, but you do like the other two, you can configure `Rummage` to not use it and write your own custom
hook.

**NOTE: `Rummage` is not like `Ransack`, and it doesn't intend to be like `Ransack`. It doesn't define functions based on search parameters.
If you'd like to have something like that, you can always configure `Rummage` to use your `Search` module for that model. This
is why Rummage has been made configurable.**

To see an example usage of `rummage`, check [this](https://github.com/annkissam/rummage_ecto_example) repository.

## Installation

This package is [available in Hex](https://hexdocs.pm/rummage_ecto/), and can be installed as:

  - Add `rummage_ecto` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rummage_ecto, "~> 2.0.0-rc.0"}]
    end
    ```

## Blogs

### Current Blogs:

  - [Rummage Demo & Basics](https://medium.com/aditya7iyengar/searching-sorting-and-pagination-in-elixir-phoenix-with-rummage-part-1-933106ec50ca#.der0yrnvq)
  - [Using Rummage.Ecto](https://medium.com/aditya7iyengar/searching-sorting-and-pagination-in-elixir-phoenix-with-rummage-part-2-8e36558984c2#.vviioi5ia)
  - [Using Rummage.Phoenix: Part 1](https://medium.com/aditya7iyengar/searching-sorting-and-pagination-in-elixir-phoenix-with-rummage-part-3-7cf5023bc226#.q08478ud2)

### Coming up next:

  - Using Rummage.Phoenix: Part 2
  - Using the Rummage Search hook
  - Using the Rummage Sort hook
  - Writing a Custom Rummage.Ecto Hook
  - Writing a Custom Rummage.Phoenix HTML helper

## Hooks

- Hooks are modules (that use `Rummage.Ecto.Hook`) and implement callbacks for
`Rummage.Ecto.Hook` behaviour. Each ecto operation which can transform the
query is defined by a `Hook`. Hooks have `run/2` function using which they
can transform an `Ecto.Queryable` variable and have `format_params/3` function
using which they can transform params passed to them through `rummage_ecto`


## Configuration

  - **NOTE: This is Optional. If no configuration is provided, `Rummage` will use default hooks and `AppName.Repo` as the repo**
  - If you want to override any of the `Rummage` default hooks,
    add `rummage_ecto` config to your list of configs in `dev.exs`:

    ```elixir
    config :rummage_ecto,
      Rummage.Ecto,
      search: MyApp.SearchModule
    ```

  - For configuring a repo:

    ```elixir
    config :rummage_ecto,
      Rummage.Ecto,
      repo: MyApp.Repo # This can be overridden per model basis, if need be.
    ```

  - Other config options are: `repo`, `sort`, `paginate`, `per_page`

  - `Rummage.Ecto` can be configured globally with a `per_page` value (which can be overridden for a model).
    If you want to set different `per_page` for different the models, add it to `model.exs` file while using `Rummage.Ecto`
    as shown in the [Advanced Usage Section](#advanced-usage).


## Usage

`Rummage.Ecto` comes with a lot of powerful features which are available right away,
without writing a whole lot of code.

Below are the ways `Rummage.Ecto` can be used:

### Basic Usage:

  - Add the `Repo` of your app and the desired `per_page` (if using Rummage's Pagination) to the `rummage_ecto` configuration in `config.exs`:

  ```elixir
  config :rummage_ecto, Rummage.Ecto,
    repo: MyApp.Repo,
    per_page: 10
  ```

  - And you should be able to use `Rummage.Ecto` with any `Ecto` model.

### Advanced Usage:

  - If you'd like to override any of `Rummage`'s default hooks with your custom hook, add the `CustomHook` of your app with the desired operation to the
  `rummage_ecto` configuration in `config.exs`:

  ```elixir
  config :rummage_ecto, Rummage.Ecto,
    repo: MyApp.Repo,
    search: MyApp.SearchModule,
    paginate: MyApp.PaginateModule
  ```

  - When using `Rummage.Ecto` with an app that has multiple `Repo`s, or when there's a need to configure `Repo` per model basis, it can be passed along with
  with the call to `Rummage.Ecto`. This overrides the default repo set in the configuration:

  ```elixir
  {queryable, rummage} = Product
    |> Rummage.Ecto.rummage(rummage, repo: MyApp.Repo2)
  ```

  - And you should be able to use `Rummage.Ecto` with `Product` model which is in a different `Repo` than the default one.


## Examples

  - Setting up the application above will allow us to do the following:

  ```elixir
  rummage = %{
    search: %{field_1 => %{search_type: :like, search_term: "field_!"}},
    sort: %{field: :field1, order: :asc},
    paginate: %{per_page: 5, page: 1}
  }

  {queryable, rummage} = Product
    |> Rummage.Ecto.rummage(rummage)

  products = queryable
    |> Product.another_operation # <-- Since `Rummage` is Ecto, we can pipe the result queryable into another queryable operation.
    |> Repo.all
  ```

  - Rummage responds to `params` with keys: `search`, `sort` and/or `paginate`. It doesn't need to have all the keys, or any keys for that matter.
    If invalid keys are passed, they won't alter any operations in rummage. Here's an example of `Rummage` params:

  ```elixir
  rummage = %{
    search: %{field_1 => %{search_type: :like, search_term: "field_!"}},
    sort: %{field: :field1, order: :asc},
    paginate: %{per_page: 5, page: 1}
  }
  ```

# Rummage.Ecto

`Rummage.Ecto` is a simple framework that can be used to alter Ecto queries with Search, Sort and Paginate operations.

It accomplishes the above operations by using `Hooks`, which are modules that implement `Rumamge.Ecto.Hook` behavior.
Each operation: Search, Sort and Paginate have their hooks defined in Rummage. By doing this, Rummage is completely
configurable. For example, if you don't like one of the implementations of Rummage, but like the other two,
 you can configure Rummage to not use it.


**NOTE: Rummage is not like Ransack, and doesn't intend to be either. It doesn't add functions based on search params.
If you'd like to have that for a model, you can always configure Rummage to use your Search module for that model. This
is why Rummage has been made configurable.**

## Installation

This package is [available in Hex](https://hexdocs.pm/rummage_ecto/api-reference.html), and can be installed as:

  1. Add `rummage_ecto` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rummage_ecto, "~> 0.2.0"}]
    end
    ```

  2. Ensure `rummage_ecto` is started before your application:

    ```elixir
    def application do
      [applications: [:rummage_ecto]]
    end
    ```


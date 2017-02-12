# Rummage

Rummage.Ecto is a simple framework that can be used to alter Ecto queries with Search, Sort and Paginate operations.

It accomplishes the above operations by using `Hooks`, which are modules thatimplement `Rumamge.Ecto.Hook` behavior.
Each operation: Search, Sort and Paginate have their hooks defined in Rummage. By doing this, Rummage is completely
configurable. For example, if you don't like one of the implementations of Rummage, but like the other two,
 you can configure Rummage to not use it.


**NOTE: Rummage is not like Ransack, and doesn't intend to be either. It doesn't add functions based on search params.
If you'd like to have that for a model, you can always configure Rummage to use your Search module for that model. This
is why Rumamge has been made configurable.**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `rummage` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rummage, "~> 0.1.0"}]
    end
    ```

  2. Ensure `rummage` is started before your application:

    ```elixir
    def application do
      [applications: [:rummage]]
    end
    ```


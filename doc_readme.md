# Rummage.Ecto

**If you're looking for full `Phoenix` support, `Rummage.Phoenix` uses `Rumamge.Ecto` and adds `HTML` and `Controller` support
to it. You can check `Rummage.Phoenix` out by clicking [here](https://github.com/Excipients/rummage_phoenix)**

**Please refer for `CHANGELOG` for version specific changes**

`Rummage.Ecto` is a framework that can be used to alter `Ecto` queries with Search, Sort and Paginate operations.

It accomplishes the above operations by using `Hooks`, which are modules that implement `Rumamge.Ecto.Hook` behavior.
Each operation: `Search`, `Sort` and `Paginate` have their hooks defined in `Rummage`. By doing this, `Rummage` is completely
configurable.

For example, if you don't like one of the implementations of `Rummage`, but like the other two, you can configure `Rummage` to not use it.

**NOTE: `Rummage` is not like `Ransack`, and doesn't intend to be. It doesn't define functions based on search params.
If you'd like to have that for a model, you can always configure `Rummage` to use your `Search` module for that model. This
is why Rummage has been made configurable.**

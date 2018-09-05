# Versions CHANGELOG

## Version 2.0.0-rc.0

- Change in namespace/module names:
  * Replace `Rummage.Ecto.Hooks` with `Rummage.Ecto.Hook`.
  * Replace `Rummage.Ecto.CustomHooks` with `Rummage.Ecto.CustomHook`.

- Introducing `Rummage.Ecto.Schema`:

- Changes to `Rummage.Ecto.Hook.Search`:

- Changes to `Rummage.Ecto.Hook.Sort`:

- Changes to `Rummage.Ecto.Hook.Paginate`:

- Changes in Configurations:



## Version: 1.3.0-rc.0

- Better Behaviour definition for Hooks.
  * Add `__using__` macro, instead of using module_attribute `@behviour`.
  * Use better function names `run/2` and `format_params`,
  * Use `defoverridable` for `@behaviour` callbacks.

- Make Native hooks more generalized instead of targeted for `phoenix`.
  * Use `atoms` over `strings` for keys in maps and params.
  * Keep hooks more agnostic of configurations.
  * Make Rummage.Ecto delegate configurations to hooks.

- The return of `Rummage.Ecto.__using__/1` macro.
  * This allows `rummage_ecto` to resolve configurations at compile time.
  * This allows better/easier usage of `Rummage.Ecto`.

- App specific configurations.
  * `config :appname, Rummage.Ecto .....` instead of `config: :rummage_ecto, Rummage.Ecto`.
  *  This allows using rummage with two different apps in an umbrella app with different rummage configurations.
  * These configurations are loaded with the help of `__using__` macro, based on the application the module belongs to.

- Search hook has `search_expr`.
  * This allows usage of `or_where` and `not_where` queries.
  * Defaults to `where`.

- Search hook has `search_type` : `is_nil`
  * This allows for searching for `NULL` or `NOT NULL`

- Tested/Examples with different `field_types`, `boolean`, `float`, `string` etc.

- Paginate hook works with or without a `primary_key`:
  * the default paginate hook used to work only for Schemas with `id` as primary keys, now it works for all and even Schemas without a primary key.

- Keyset Pagination CustomHook.
  * Adds faster/lighter weight pagination option.
  * Documentation specifies when to use it and when not to.

- SimpleSort and SimpleSearch CustomHook updates.
  * Same as sort and search, but without associations, so cleaner and faster.

- Better documentation.
  * Search and Sort associations are better documented.
  * CustomHooks are better documented.


## Version: 1.2.0

- Faster Pagination Hooks

## Version: 1.1.0

### Changes to Rummage as whole:
- More functional way of calling `Rummage`:
  - Instead of `EctoSchema.rummage(query, rummage)`, call `Rummage.Ecto.rummage(query, rummage)`

- Default `Hooks` can handle any number of associations.

### Changes to complexity:
- `Hooks` are more independent of each other due to a newly introduced `before_hook` feature. This
allows us to format `rummage_params` based on what a hook is expecting and keep the code clean.

### In Progress:
- A `CustomHook` with `key-set` pagination based on [this](http://use-the-index-luke.com/no-offset) link.


## Version: 1.0.0

### Major changes to default hooks:
  - `Search`:
    - Can now search more than just `like`.
    - Added case insensitive `like` feature.
    - Added support for `like`, `ilike`, `eq`, `gt`, `lt`, `gteq`, `lteq` as `search_types` (Refer to docs for more details)
    - Can search on an association field (Refer to docs for more details)

  - `Sort`:
    - Added case insensitive `sort`.
    - Can sort on an association field (Refer to docs for more details)

  - `Pagination`: NO CHANGES

### Change in `rummage` struct syntaxes:
  - `search` key:
    - Earlier:
      ```elixir
      rummage = %{"search" => %{"field_1" => "field_!"}}
      ```

    - Now:
      ```elixir
      rummage = %{"search" => %{"field_1" => %{"assoc" => ["assoc_1", "assoc_2"], "search_type" => "like", "search_term" => "field_!"}}
      ```

  - `sort` key:
    - Earlier:
      ```elixir
     rummage = %{"sort" => "field_1.asc"}
      ```

    - Now:
      ```elixir
      rummage = %{"sort" => %{"assoc" => ["assoc_1", "assoc_2"], "field" => "field_1.asc"}}
      ```

  - `paginate` key: NO CHANGES

### Custom Hooks Examples Included:
  - Included some examples for custom hooks:
    - `Rumamage.Ecto.CustomHooks.SimpleSearch`: Vanilla search feature with support for only `like`
    - `Rumamage.Ecto.CustomHooks.SimpleSort`: Vanilla sort feature


## Version: 0.6.0

- First version with Rummage.Phoenix compatibility
- First major version


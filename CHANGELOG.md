# Versions CHANGELOG

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


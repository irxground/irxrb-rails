IrxrbRails
==========

This gem provide some rails feature

- Database View


Database View
-------------

### Install

If you use (Rails.version < 4.1.0), nothing to do.

If you use (Rails.version >= 4.1.0) and test, you must rewrite `rails_helper` following way.

from:

```ruby
ActiveRecord::Migration.maintain_test_schema!
```

after:

```ruby
Irxrb::Rails::DBViewMigrator.migrate do
  ActiveRecord::Migration.maintain_test_schema!
end
```


### How this work.

RakeTask `db:migrate:drop` is invoked before `db:migrate` and `db:views:migrate` is invoked after `db:migrate`

`db:views:drop` task drop all DB views.
`db:views:migrate` task create DB views from `db/migrate/views` directories.

### Sample

Following script in `db/migrate/views/concat_user.rb` create `concat_user` view.

```ruby
Irxrb::Rails::DBViewMigrator.define do
  create_view :concat_user do
    "SELECT id, (first_name || ' ' || last_name) concat_name FROM users"
  end
end
```

[Learn more](doc/db_view_migrator.md)



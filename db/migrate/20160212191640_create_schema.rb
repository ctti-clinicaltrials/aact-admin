class CreateSchema < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE SCHEMA IF NOT EXISTS admin;
      ALTER role ctti set search_path to admin, public;
      GRANT usage on schema admin to ctti;
      GRANT create on schema admin to ctti;
    SQL
  end

  def down
    execute <<-SQL
      DROP SCHEMA IF EXISTS admin CASCADE;
      ALTER role ctti set search_path to public;
    SQL
  end

end

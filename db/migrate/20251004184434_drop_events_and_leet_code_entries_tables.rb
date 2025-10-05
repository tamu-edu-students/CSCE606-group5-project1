class DropEventsAndLeetCodeEntriesTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :events if ActiveRecord::Base.connection.table_exists?(:events)
    drop_table :leet_code_entries if ActiveRecord::Base.connection.table_exists?(:leet_code_entries)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't restore dropped tables"
  end
end

# Removes obsolete tables replaced by improved session-based architecture
class DropEventsAndLeetCodeEntriesTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :events if ActiveRecord::Base.connection.table_exists?(:events)              # Remove local events (using Google Calendar instead)
    drop_table :leet_code_entries if ActiveRecord::Base.connection.table_exists?(:leet_code_entries)  # Remove old entries (using sessions model)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't restore dropped tables"
  end
end

class AddIndexesToJustStartEndTime < ActiveRecord::Migration
  def self.up
    # I thought my last index creation did this automatically, but I guess i was wrong
    add_index(:windows, :start_time)
    add_index(:windows, :end_time)
  end

  def self.down
    remove_index(:windows, :start_time)
    remove_index(:windows, :end_time)
  end
end

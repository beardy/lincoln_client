class AddIndexToWindow < ActiveRecord::Migration
  def self.up
     add_index(:windows, [:start_time, :end_time])
  end

  def self.down
    remove_index(:windows, [:start_time, :end_time])
  end
end

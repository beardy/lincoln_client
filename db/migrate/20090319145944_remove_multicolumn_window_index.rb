class RemoveMulticolumnWindowIndex < ActiveRecord::Migration
  def self.up
    remove_index(:windows, [:start_time, :end_time])
  end

  def self.down
    add_index(:windows, [:start_time, :end_time])
  end
end

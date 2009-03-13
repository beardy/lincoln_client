class AddStreamIdIndexToWindow < ActiveRecord::Migration
  def self.up
    add_index(:windows, :stream_id)
  end

  def self.down
    remove_index(:windows, :stream_id)
  end
end

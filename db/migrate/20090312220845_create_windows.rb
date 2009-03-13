class CreateWindows < ActiveRecord::Migration
  def self.up
    create_table :windows do |t|
      t.integer :stream_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :num_packets_incoming
      t.integer :num_packets_outgoing
      t.integer :size_packets_incoming
      t.integer :size_packets_outgoing

      # t.timestamps
    end
  end

  def self.down
    drop_table :windows
  end
end

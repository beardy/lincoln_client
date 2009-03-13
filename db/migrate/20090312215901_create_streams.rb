class CreateStreams < ActiveRecord::Migration
  def self.up
    create_table :streams do |t|
      t.column :raw_ip_incoming, 'integer unsigned'
      t.column :raw_ip_outgoing, 'integer unsigned'
      t.integer :port_in
      t.integer :port_out
      t.integer :protocol

      t.timestamps
    end
  end

  def self.down
    drop_table :streams
  end
end

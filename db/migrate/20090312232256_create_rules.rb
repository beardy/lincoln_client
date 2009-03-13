class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.integer :group_id
      t.column :raw_ip_incoming_start, 'integer unsigned'
      t.column :raw_ip_incoming_end, 'integer unsigned'
      t.column :raw_ip_outgoing_start, 'integer unsigned'
      t.column :raw_ip_outgoing_end, 'integer unsigned'
      t.integer :port_incoming_start
      t.integer :port_incoming_end
      t.integer :port_outgoing_start
      t.integer :port_outgoing_end
      t.integer :protocol
      t.boolean :not_flag

      t.timestamps
    end
  end

  def self.down
    drop_table :rules
  end
end

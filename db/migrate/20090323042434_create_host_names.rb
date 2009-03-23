class CreateHostNames < ActiveRecord::Migration
  def self.up
    create_table :host_names do |t|
      t.column :raw_ip_address, 'integer unsigned'
      t.string :name
    end
  end

  def self.down
    drop_table :host_names
  end
end

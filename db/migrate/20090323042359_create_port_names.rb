class CreatePortNames < ActiveRecord::Migration
  def self.up
    create_table :port_names do |t|
      t.integer :number
      t.string :name
    end
  end

  def self.down
    drop_table :port_names
  end
end

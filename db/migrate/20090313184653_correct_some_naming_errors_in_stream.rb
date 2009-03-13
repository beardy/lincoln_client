class CorrectSomeNamingErrorsInStream < ActiveRecord::Migration
  def self.up
    rename_column :streams, :port_in, :port_incoming
    rename_column :streams, :port_out, :port_outgoing
    remove_column :streams, :updated_at
    remove_column :streams, :created_at
  end

  def self.down
    add_column :streams, :created_at, :datetime
    add_column :streams, :updated_at, :datetime
    rename_column :streams, :port_outgoing, :port_out
    rename_column :streams, :port_incoming, :port_in
  end
end

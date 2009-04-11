class AddColorToGroups < ActiveRecord::Migration
  def self.up
    add_column "groups", "color", :string
  end

  def self.down
  end
end

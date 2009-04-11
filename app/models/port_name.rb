class PortName < ActiveRecord::Base
  validates_uniqueness_of :number, :name
  validates_presence_of :number, :name
end

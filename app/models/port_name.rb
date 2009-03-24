class PortName < ActiveRecord::Base
  validates_uniqueness_of :number, :name
end

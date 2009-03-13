class Group < ActiveRecord::Base
  has_many :rules, :dependent => :destroy
end

class Group < ActiveRecord::Base
  has_many :rules, :dependent => :destroy
  
  # TODO: use the to_sql method 
  #  of the rules and make an aggregate 
  #  sql statement that represents all the 
  #  rule statements for this group
  # def to_sql
  #  ... combine rule's to_sql methods
  # end
end

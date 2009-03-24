class Group < ActiveRecord::Base
  has_many :rules, :dependent => :destroy
  
  def to_s
    self.name
  end
  def to_sql
    not_sql = ""
    true_sql = ""
    sql = ""
    self.rules.each do |rule|
      if rule.not_flag 
        unless not_sql.empty?
          not_sql << " AND "
        end
        not_sql << rule.to_sql
      else
        unless true_sql.empty?
          true_sql << " OR "
        end
        true_sql << rule.to_sql
      end
    end
    unless not_sql.empty?
      sql << "(" << not_sql << ")"
    end
    unless true_sql.empty?
      unless sql.empty?
        sql << " AND "
      end
      sql << "(" << true_sql << ")"
    end
    sql = sql.gsub(/(\(\))/,"").strip.empty? ? "" : sql
    sql
  end #to_sql
end

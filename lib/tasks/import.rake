require "ipaddr"
require 'faster_csv'

def get_data_path(filename)
  File.expand_path(File.join(RAILS_ROOT, 'data', filename))   
end

def default_options
  {:col_sep => "\t", :row_sep => :auto, :headers => true}
end

# convert ip addresses. 
# convert strings to ints
def clean_row(row)
  row = row.to_hash
  row['raw_ip_incoming'] = IPAddr.new(row['raw_ip_incoming']).to_i
  row['raw_ip_outgoing'] = IPAddr.new(row['raw_ip_outgoing']).to_i
  %w[port_incoming port_outgoing protocol num_packets_incoming 
    size_packets_incoming num_packets_outgoing size_packets_outgoing].each do |col|
    row[col] = row[col].to_i
  end
  row
end

# keep only those values in a hash
# that the particular model can hold
def remove_extras(hash, model)
  hash.reject do |key,value|
    # puts !(model.column_names.include?(key.to_s))
    !(model.column_names.include?(key.to_s))
  end
end

# checks if a stream contains the same values as a row
def same_stream(row,stream)
  stream && row['raw_ip_incoming'] == stream.raw_ip_incoming && row['raw_ip_outgoing'] == stream.raw_ip_outgoing
end


namespace :import do
  task :all => ['db:reset',:test,:groups,:rules]
  
  task :final => ['db:reset', :test, :port_names]
  
  task :test => :environment do
    input_file = 'data.txt'
    full_input_file = get_data_path(input_file)
    options = default_options
    
    stream = nil
    count = 0
    FasterCSV.foreach(full_input_file, options) do |row|
      row = clean_row(row)
      window = Window.new(remove_extras(row,Window))
      unless(same_stream(row,stream))
        # save previous stream, if present
        stream.save! if stream
        # create a new stream
        stream = Stream.new(remove_extras(row,Stream))
      end
      stream.windows << window
      count += 1
      if(count % 500 == 0)
        puts "Import number: #{count}"
      end #if count
    end #FasterCSV
  end #test
  
  
  # Inserts some groups into the database
  task :groups => :environment do
    group1 = Group.new(:name => "Perceptive")
    group1.save!
    group2 = Group.new(:name => "Other Traffic")
    group2.save!  
  end
  
  task :rules => :environment do
    groups = Group.find(:all)
    groups[0].rules << Rule.new(:port_incoming_start => 80, :port_incoming_end => 80)
    groups[1].rules << Rule.new(:port_incoming_start => 80, :port_incoming_end => 80, :not_flag => true)
    groups.each do |group|
      group.save!
    end
  end
  
  task :port_names => :environment do
    input_file = 'well_known_ports.csv'
    full_input_file = get_data_path(input_file)
    options = default_options
    options[:col_sep] = ","
    port_names = []
    FasterCSV.foreach(full_input_file, options) do |row|
      if row["protocol"] == "tcp"
        port_names << {:name => row["name"], :number => row["number"]}
      end
    end
    PortName.create port_names
  end
end
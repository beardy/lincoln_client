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
  %w[port_in port_out protocol num_packets_incoming 
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
  task :all => ['db:reset',:test]
  
  task :test => :environment do
    require 'faster_csv'
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
end
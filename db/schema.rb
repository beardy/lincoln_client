# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090317125241) do

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", :force => true do |t|
    t.integer  "group_id"
    t.integer  "raw_ip_incoming_start"
    t.integer  "raw_ip_incoming_end"
    t.integer  "raw_ip_outgoing_start"
    t.integer  "raw_ip_outgoing_end"
    t.integer  "port_incoming_start"
    t.integer  "port_incoming_end"
    t.integer  "port_outgoing_start"
    t.integer  "port_outgoing_end"
    t.integer  "protocol"
    t.boolean  "not_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streams", :force => true do |t|
    t.integer "raw_ip_incoming"
    t.integer "raw_ip_outgoing"
    t.integer "port_incoming"
    t.integer "port_outgoing"
    t.integer "protocol"
  end

  create_table "windows", :force => true do |t|
    t.integer  "stream_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "num_packets_incoming"
    t.integer  "num_packets_outgoing"
    t.integer  "size_packets_incoming"
    t.integer  "size_packets_outgoing"
  end

  add_index "windows", ["end_time"], :name => "index_windows_on_end_time"
  add_index "windows", ["start_time", "end_time"], :name => "index_windows_on_start_time_and_end_time"
  add_index "windows", ["start_time"], :name => "index_windows_on_start_time"
  add_index "windows", ["stream_id"], :name => "index_windows_on_stream_id"

end

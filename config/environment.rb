# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.
  
  # config.add_support_load_paths %W( #{RAILS_ROOT}/lib/graph_builder)

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  
  config.gem "calendar_date_select"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_lincoln_client_session',
    :secret      => 'b73869270a5416782acdaec22a86fc76468e71e08ee95c67c0328b5e34202b498c852022a484d63582acc16ec22947a3e0223e07b8a0442769e291a6d25c7852'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
end

require_dependency RAILS_ROOT + "/lib/graph_builders/graph_builder"
require_dependency RAILS_ROOT + "/lib/graph_builders/area_graph_builder"
require_dependency RAILS_ROOT + "/lib/graph_builders/line_graph_builder"
require_dependency RAILS_ROOT + "/lib/graph_builders/bar_graph_builder"
require_dependency RAILS_ROOT + "/lib/graph_builders/pie_graph_builder"
require_dependency RAILS_ROOT + "/lib/graph_builders/scatter_graph_builder"

require_dependency RAILS_ROOT + "/lib/graph_data/graph_data"
require_dependency RAILS_ROOT + "/lib/graph_data/graph_element"
require_dependency RAILS_ROOT + "/lib/graph_data/graph_value"

require_dependency RAILS_ROOT + "/lib/graphs/base_graph"
require_dependency RAILS_ROOT + "/lib/graphs/base_graph_all_groups"
require_dependency RAILS_ROOT + "/lib/graphs/base_graph_group_details"
require_dependency RAILS_ROOT + "/lib/graphs/scatter_graph_daily_traffic"
require_dependency RAILS_ROOT + "/lib/graphs/scatter_graph_all_groups_daily_traffic"
require_dependency RAILS_ROOT + "/lib/graphs/scatter_graph_group_details_daily_traffic"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_all_groups"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_all_groups_data_size"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_all_groups_data_size_normalized"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_all_groups_packet_count"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_all_groups_packet_count_normalized"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_group_details"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_group_details_data_size"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_group_details_data_size_normalized"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_group_details_packet_count"
require_dependency RAILS_ROOT + "/lib/graphs/timeline_graph_group_details_packet_count_normalized"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_all_groups"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_all_groups_groups"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_all_groups_ip_addresses"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_group_details"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_group_details_ip_addresses"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_group_details_ports"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_group_details_ports_incoming"
require_dependency RAILS_ROOT + "/lib/graphs/top_graph_group_details_ports_outgoing"
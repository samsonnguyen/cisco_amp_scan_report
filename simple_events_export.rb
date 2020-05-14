require 'rubygems'
require 'bundler/setup'
require 'optparse'
require 'optparse/date'
require 'date'
require 'csv'
begin
  require 'byebug'
rescue LoadError
end

require_relative 'lib/computers/computers'
require_relative 'lib/groups/groups'
require_relative 'lib/events/events'
require_relative 'lib/compromises/compromises'

class ScriptOptions
  attr_accessor :groups, :api_key, :api_secret, :start_time, :force_cache_update, :event_type_ids
  REQUIRED = %w(groups api_key api_secret start_time event_type_ids)

  def initialize(args)
    OptionParser.new do |opts|
      opts.banner = "Usage: clean_scans.rb [options] --help"
  
      opts.on("--groups 'group 1','group 2','group 3'", :REQUIRED, Array, "Comma delimited 'list' of group names") do |groups|
        @groups = groups.map(&:strip)
      end

      opts.on("--event_type_ids '554696714,", :REQUIRED, Array, "Comma delimited list of event_type_ids") do |event_type_id|
        @event_type_ids = event_type_id.map(&:to_i)
      end

      opts.on("--api_key MANDATORY", :REQUIRED) do |api_key|
        @api_key = api_key
      end

      opts.on("--api_secret MANDATORY", :REQUIRED) do |api_secret|
        @api_secret = api_secret
      end

      opts.on("--start_time MANDATORY", :REQUIRED, DateTime) do |start_time|
        @start_time = start_time
      end
    end.parse!(args)
    check_required_args
  end

  def self.parse(args)
    ScriptOptions.new(args)
  end

  def check_required_args
    REQUIRED.each do |required_arg|
      raise StandardError.new("Missing a required argument '--#{required_arg}'', please run with --help for more info") if send(required_arg.to_sym).nil?
    end
  end

end


class SimpleEventsExport
  def initialize
    options = ScriptOptions.parse(ARGV)
    groups = Groups.new(options)
    events = Events.new(options, groups).get
    filename = "events_csv_#{options.groups.to_s.gsub!(/[^0-9A-Za-z.\-]/, '_')}.csv"
    File.open(filename, "w", :write_headers => true) do |csv|
      csv.write Events.header_row.to_s
      events.each do |event|
        csv.write Events.to_csv(event).to_s
      end
    end
    puts "file written to #{filename}"
  end
end

SimpleEventsExport.new
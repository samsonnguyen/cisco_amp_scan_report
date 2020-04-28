require 'rubygems'
require 'bundler/setup'
require 'optparse'
require 'optparse/date'
require 'date'
require 'csv'

require_relative 'lib/computers/computers'
require_relative 'lib/groups/groups'
require_relative 'lib/events/events'

class ScriptOptions
  attr_accessor :groups, :group_mapping_file, :host_mapping_file, :api_key, :api_secret, :start_time
  REQUIRED = %w(groups group_mapping_file host_mapping_file api_key api_secret start_time)

  def initialize(args)
    OptionParser.new do |opts|
      opts.banner = "Usage: clean_scans.rb [options] --help"
  
      opts.on("--groups 'group 1','group 2','group 3'", :REQUIRED, Array, "Comma delimited 'list' of group names") do |groups|
        @groups = groups
      end

      opts.on("--group_mapping_file MANDATORY", :REQUIRED) do |group_mapping_file|
        @group_mapping_file = group_mapping_file
      end

      opts.on("--host_mapping_file MANDATORY", :REQUIRED) do |host_mapping_file|
        @host_mapping_file = host_mapping_file
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

class ScanReport
  attr_accessor :options, :groups, :computers

  def initialize
    @options = ScriptOptions.parse(ARGV)
    @groups = Groups.new(options.group_mapping_file, options.groups)
    @computers = Computers.new(options.host_mapping_file)
    
    # puts options.groups
    # puts @groups.group_guids

    events = Events.new(@options, @groups).get
    events.each do |event|
      @computers.process_event(event)
    end
    filename = "#{options.groups.to_s.gsub!(/[^0-9A-Za-z.\-]/, '_')}.csv"
    File.open(filename, "w", :write_headers => true) do |csv|
      csv.write Computer.header_row.to_s
      @computers.each do |computer|
        csv.write computer.to_csv.to_s
      end
    end
    puts "file written to #{filename}"
  end

  def get_events
    
  end

end


ScanReport.new
require 'json'
require_relative '../events/events'
require_relative './computer'
require_relative '../api_client'
require_relative '../simple_file_cache'

class Computers
  include Enumerable
  include ApiClient
  include SimpleFileCache
  attr_accessor :mapping, :computers

  def initialize(options)
    @options = options
    @mapping ||= {}
    if options.host_mapping_file
      json_data = JSON.parse(File.read(@options.host_mapping_file))
      parse(json_data["data"])
    else
      invalidate_cache("computers") if @options.force_cache_update
      parse(with_cache("computers") {get})
    end
    @computers = Hash.new()
  end

  def base_uri
    URI('https://api.amp.cisco.com/v1/computers')
  end

  def base_params
    {}
  end

  def hostname(guid)
    mapping[guid]
  end

  def each
    @computers.values.map {|computer| yield computer}
  end

  def << (computer)
    @computers << computer
  end

  def process_event(event)
    guid = event["connector_guid"]
    computer = @computers[guid] || Computer.new
    computer.hostname = hostname(guid) if computer.hostname.nil?
    computer.guid = guid if computer.guid.nil?
    computer.process_event(event)
    @computers[guid] = computer
  end

  private 

  def parse(json_data)
    json_data.map do |computer|
      @mapping[computer["connector_guid"]] = computer["hostname"]
    end
    puts "parsed #{mapping.size} computers"
  end
end

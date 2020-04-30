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
    mapping[guid]["hostname"]
  end

  def group_guid(guid)
    mapping[guid]["group_guid"]
  end

  def each
    @computers.values.map {|computer| yield computer}
  end

  def << (computer)
    @computers << computer
  end

  def process_event(event)
    guid = event["connector_guid"]
    computer = @computers[guid] || Computer.new(@mapping[guid])
    computer.process_event(event)
    @computers[guid] = computer
  end

  def with_groupnames(groups)
    @computers.each do |guid, computer|
      computer.group_name = groups.groupname(computer.group_guid)
    end
    self
  end

  def with_compromises(compromises)
    return self unless compromises.enabled?
    @computers.each do |guid, computer|
      computer.compromises = compromises.for_computer(computer.guid)
    end
    self
  end

  private 

  def parse(json_data)
    json_data.map do |computer|
      @mapping[computer["connector_guid"]] = computer
    end
    puts "parsed #{mapping.size} computers"
  end
end

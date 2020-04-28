require 'json'
require_relative '../events/events'
require_relative './computer'
class Computers
  include Enumerable
  attr_accessor :mapping, :computers

  def initialize(group_mapping_file)
    @mapping ||= {}
    json_data = JSON.parse(File.read(group_mapping_file))
    parse(json_data)
    @computers = Hash.new()
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

  def parse(json)
    json["data"].map do |computer|
      @mapping[computer["connector_guid"]] = computer["hostname"]
      # @mapping[computer["connector_guid"]] = Computer.new(hostname: computer["hostname"], guid: computer["connector_guid"])
    end
    puts "parsed #{mapping.size} computers"
  end
end

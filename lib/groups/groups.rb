require 'json'
require_relative '../api_client'
require_relative '../simple_file_cache'
require_relative 'group'

class Groups
  include ApiClient
  include SimpleFileCache
  attr_accessor :mapping, :groups

  def initialize(options)
    @options = options
    @groups = Group.new # establish a nil group as root
    @mapping ||= {}
    if @options.group_mapping_file
      json_data = JSON.parse(File.read(@options.group_mapping_file))
      parse(json_data["data"])
    else
      invalidate_cache("groups") if @options.force_cache_update
      parse(with_cache("groups") {get})
    end
  end

  def guid(name)
    group = mapping[name]
    group["guid"] if group
  end

  def groupname(guid)
    @reverse_mapping ||= @mapping.transform_values{ |value| value["guid"] }.invert
    @reverse_mapping[guid]
  end

  def get_group(name)
    @groups.get(guid(name))
  end

  def base_uri
    URI('https://api.amp.cisco.com/v1/groups')
  end

  def base_params
    {}
  end

  def guids_including_descedants
    @options.groups.map do |group_name|
      get_group(group_name).guids_including_descedants
    end.flatten.compact
  end

  def guids
    @options.groups.map do |group_name|
      guid(group_name)
    end
  end

  private

  def parse(json_data)
    json_data.map do |group|
      @mapping[group["name"]] = group
      @groups.insert(group)
    end
    puts "parsed #{mapping.size} groups"
  end
end

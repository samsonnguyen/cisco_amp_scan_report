require 'json'
require_relative '../api_client'
require_relative '../simple_file_cache'

class Groups
  include ApiClient
  include SimpleFileCache
  attr_accessor :mapping, :group_guids

  def initialize(options)
    @options = options
    @mapping ||= {}
    if @options.group_mapping_file
      json_data = JSON.parse(File.read(@options.group_mapping_file))
      parse(json_data["data"])
    else
      invalidate_cache("groups") if @options.force_cache_update
      parse(with_cache("groups") {get})
    end
    @group_guids = @options.groups.collect do |group_name|
      guid(group_name)
    end
  end

  def guid(name)
    mapping[name]
  end

  def base_uri
    URI('https://api.amp.cisco.com/v1/groups')
  end

  def base_params
    {}
  end

  private

  def parse(json_data)
    json_data.map do |group|
      @mapping[group["name"]] = group["guid"]
    end
    puts "parsed #{mapping.size} groups"
  end
end

require 'json'
class Groups
  attr_accessor :mapping, :group_guids
  def initialize(group_mapping_file, group_names)
    @mapping ||= {}
    json_data = JSON.parse(File.read(group_mapping_file))
    parse(json_data)
    @group_guids = group_names.collect do |group_name|
      guid(group_name)
    end
  end

  def guid(name)
    mapping[name]
  end

  private

  def parse(json)
    json["data"].map do |group|
      @mapping[group["name"]] = group["guid"]
    end
    puts "parsed #{mapping.size} groups"
  end
end

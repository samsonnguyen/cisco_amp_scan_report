require 'net/http'
require 'uri'
require 'json'
require_relative '../api_client'
class Events
  include ApiClient
  EVENT_TYPES = {
    :scan_started => 554696714, ## scan started
    :scan_completed_clean => 554696715, ## Scan Completed, No Detections
    :scan_completed_dirty => 1091567628, ## Scan Completed With Detections
    :scan_failed => 2165309453, ## Scan Failed
    :threat_detected => 1090519054 ## Threat Detected
 }.freeze
  attr_accessor :events

  EXPORTABLE_DATA_MAP = [
    :date,
    :event_type,
    :severity,
    :connector_guid,
    :group_names,
    {computer: [
      :hostname,
      :external_ip
    ]},
    :detection,
    {file: [
      :file_name,
      :file_path,
      identity: [
        :sha256
      ]
    ]},
    {network_info: [
      :remote_ip,
      :remote_port,
      :dirty_url
    ]},
    :sha256,
    :sha1,
    :md5,
    {file: [
      {parent: [
        :file_name,
        {identity: [
          :sha256,
          :sha256_other
        ]}
      ]},
      {archived_file: [
          :sha256
        ]
      },
    ]},
    {attack_details: [
      :application,
      :attacked_module,
      :base_address,
      :suspicious_files
    ]},
    :fault_event_title,
    {cloud_ioc: [
      :short_description 
    ]},
    :user_name,
    {vulnerabilities: [
      :name,
      :version
    ]}
  ]

  def initialize(options, groups)
    @options = options
    @groups = groups
  end

  def base_uri
    URI('https://api.amp.cisco.com/v1/events')
  end

  def base_params
    {
      :start_date => @options.start_time.iso8601,
      :"event_type[]" => @options.respond_to?(:event_type_ids) ? @options.event_type_ids : EVENT_TYPES.values,
      :"group_guid[]" => @groups.guids
    }
  end

  def to_csv(event)
    CSV::Row.new(header_row, append_to_row([], decorate(event), EXPORTABLE_DATA_MAP))
  end

  def header_row
    @@header_row ||= CSV::Row.new(flatten_header(EXPORTABLE_DATA_MAP), flatten_header(EXPORTABLE_DATA_MAP), true)
  end

  private 
  
  def flatten_header(headers, prefix = nil)
    flattened_headers = []
    headers.each do |item|
      if item.is_a? Hash
        item.each do |key,values|
          new_prefix = key
          new_prefix = "#{prefix}_#{key}" if prefix
            flattened_headers << flatten_header(values, new_prefix)
        end
      else
        if prefix
        flattened_headers << "#{prefix}_#{item}"
        else
          flattened_headers << item.to_s
        end
        
      end
    end
    flattened_headers.flatten
  end

  def append_to_row(row, data, mappings)
    mappings.each do |mapping|
      if mapping.is_a? Hash
        mapping.each do |key, values|
          if  data[key.to_s]
            append_to_row(row, data[key.to_s], values)
          else
            count_nested_values(values).times do 
              row << nil
            end            
          end
        end
      else
        row << data[mapping.to_s]
      end
    end
    row
  end

  def decorate(event)
    group_guids = event["group_guids"]
    if group_guids
      group_names = group_guids.map { |guid| @groups.groupname(guid) }
      event["group_names"] = group_names.join(', ')
    end
    event
  end


  def count_nested_values(mapping)
    return 1 if mapping.is_a? Symbol
    return mapping.count if mapping.all? { |element| element.is_a? Symbol }
    mapping.inject(0) { |sum, element| sum + count_nested_values(element) }
  end
end

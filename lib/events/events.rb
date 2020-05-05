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
      :"event_type[]" => EVENT_TYPES.values,
      :"group_guid[]" => @groups.guids_including_descedants
    }
  end
end

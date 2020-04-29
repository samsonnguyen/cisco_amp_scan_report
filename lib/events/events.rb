require 'net/http'
require 'uri'
require 'json'
class Events
  EVENT_TYPES = {
    :scan_started => 554696714, ## scan started
    :scan_completed_clean => 554696715, ## Scan Completed, No Detections
    :scan_completed_dirty => 1091567628, ## Scan Completed With Detections
    :scan_failed => 2165309453, ## Scan Failed
    :threat_detected => 1090519054 ## Threat Detected
 }.freeze
  attr_accessor :events
  LIMIT = 500


  def initialize(options, groups)
    @options = options
    @groups = groups
  end

  def get
    data = []
    last_result_index = 0
    total = 1
    while(last_result_index < total) do
      batch = get_batch(offset: last_result_index)
      data.concat(batch["data"])
      total = batch["metadata"]["results"]["total"]
      index = batch["metadata"]["results"]["index"]
      current_item_count = batch["metadata"]["results"]["current_item_count"]
      last_result_index = index + current_item_count
    end
    data
  end

  def events_uri
    URI('https://api.amp.cisco.com/v1/events')
  end


  def get_batch(offset: 0)
    uri = events_uri
    params = base_params.merge({
      :limit => LIMIT,
      :offset => offset
    })
    uri.query = URI.encode_www_form(params)
    
    res = make_request(uri)
    raise "The API returned a non 200 reponse #{res.body}" if res.code.to_i != 200
    JSON.parse(res.body)
  end

  def add_body

  end
  
  def base_params
    {
      :start_date => @options.start_time.iso8601,
      :"event_type[]" => EVENT_TYPES.values,
      :"group_guid[]" => @groups.group_guids
    }
  end

  def make_request(uri)
    req = Net::HTTP::Get.new(uri)
    req.basic_auth @options.api_key, @options.api_secret

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }
  end

end

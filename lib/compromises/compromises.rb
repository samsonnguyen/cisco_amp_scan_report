
require_relative '../api_client'
require_relative '../simple_file_cache'

class Compromises
  include ApiClient
  include SimpleFileCache
  attr_accessor :mapping, :computers, :enabled_for_business

  STATUSES = [:unresolved, :in_progress]

  def initialize(options)
    @options = options
    @mapping = {}
    invalidate_cache if @options.force_cache_update
    begin
      parse(with_cache {get})
      @enabled_for_business = true
    rescue ApiClient::InvalidResponse => exception
      @enabled_for_business = false
    end
  end

  def base_uri
    URI('https://api.amp.cisco.com/v1/compromises')
  end

  def base_params
    {}
  end

  def parse(json_data)
    json_data.each do |compromise|
      # debugger
      if STATUSES.include?(compromise["status"].to_sym)
        computer_guid = compromise["computer"]["connector_guid"]
        @mapping[computer_guid] = {unresolved: 0, in_progress: 0} if @mapping[computer_guid].nil?
        
        case compromise["status"]
        when :unresolved.to_s
          @mapping[computer_guid][:unresolved] += 1
        when :in_progress.to_s
          @mapping[computer_guid][:in_progress] += 1
        end
        # puts "#{computer_guid} #{@mapping[computer_guid]}"
      end
    end
  end

  def enabled?
    !!@enabled_for_business
  end

  def for_computer(computer_guid)
    @mapping[computer_guid]
  end

end

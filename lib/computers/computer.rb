require_relative '../events/events'
require 'csv'
require 'time'

class Computer
  HEADER = %w(hostname guid scan_started scan_finished scan_failed detection_from_scan detections)
  attr_accessor :scan_started, :scan_failed, :scan_finished, :detection_from_scan, :detections, :guid, :hostname

  def initialize
    @detection_from_scan = false
    @detections = []
  end

  def process_event(event)
    case event["event_type_id"]
    when Events::EVENT_TYPES[:scan_started]
      @scan_started = event["timestamp"] if scan_started.nil? || event["timestamp"] < scan_started
    when Events::EVENT_TYPES[:scan_completed_clean]
      @scan_finished = event["timestamp"] if scan_finished.nil? || event["timestamp"] > scan_finished
    when Events::EVENT_TYPES[:scan_completed_dirty]
      @scan_finished = event["timestamp"] if scan_finished.nil? || event["timestamp"] > scan_finished
      detection_from_scan = true
    when Events::EVENT_TYPES[:scan_failed]
      continue if @scan_failed
      @scan_finished = event["timestamp"] if scan_finished.nil? || event["timestamp"] > scan_finished
      @scan_failed = event["timestamp"]
    when Events::EVENT_TYPES[:threat_detected]
      @detections << event["file"]["identity"]["sha256"]
      @detections.uniq!
    end
    self
  end

  def to_csv
    CSV::Row.new(HEADER, [
      hostname,
      guid,
      (scan_started.nil? ? nil : Time.at(scan_started)),
      (scan_finished.nil? ? nil : Time.at(scan_finished)),
      (scan_failed.nil? ? nil : Time.at(scan_failed)),
      detection_from_scan,
      detections.to_s])
  end

  def self.header_row
    CSV::Row.new(HEADER, HEADER, true)
  end

end


require_relative '../events/events'
require 'csv'
require 'time'

class Computer
  COLUMNS = [:hostname, :group_name, :guid, :scan_started, :scan_finished, :scan_failed, :detection_from_scan, :detections]
  HEADER = COLUMNS.collect(&:to_s)
  attr_accessor *COLUMNS, :compromises, :group_guid

  def initialize(guid, computer_hash)
    @detection_from_scan = false
    @detections = []
    @guid = guid
    if !computer_hash.nil?
      @group_guid = computer_hash["group_guid"]
      @hostname = computer_hash["hostname"]
    end
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
    values = [
      hostname,
      group_name,
      guid,
      (scan_started.nil? ? nil : Time.at(scan_started)),
      (scan_finished.nil? ? nil : Time.at(scan_finished)),
      (scan_failed.nil? ? nil : Time.at(scan_failed)),
      detection_from_scan,
      detections.to_s]
    if compromises
      values << compromises[:unresolved]
      values << compromises[:in_progress]
    else
      values << 0
      values << 0
    end
    CSV::Row.new(Computer.header(!compromises.nil?), values)
  end

  def self.header_row(with_compromises = false)
    CSV::Row.new(header(with_compromises), header(with_compromises), true)
  end

  def self.header(with_compromises = false)
    return HEADER + ["unresolved_compromises", "inprogress_compromises"] if with_compromises
    HEADER
  end
  

end


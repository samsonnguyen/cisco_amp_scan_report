Usage

For use with [Cisco AMP for Endpoints](https://www.cisco.com/c/en/us/products/security/amp-for-endpoints/index.html).

This script will query the api and generate an aggregate report by hosts for agents with scans or detections.


Get json output from the following api endpoints and store locally.

* api.amp.cisco.com/v1/groups
* api.amp.cisco.com/v1/computers


Run the script

```
ruby scan_report.rb --groups "Audit" --group_mapping_file "groups.json" --host_mapping_file "computers.json" --api_key "6d460649d31d99b3f429" --api_secret="878207c0-e62e-4c95-b76e-fb64ecfb2c72" --start_time "2020-04-28 04:22"
```

Parameters:

| parameter | description |
| --- | --- |
| --groups | A comma seperated list of group names (e.g "Audit, Protect") |
| --start_time | ISO formatted time such as 2020-04-28 04:22 |
| --group_mapping_file | path to json output from v1/groups api endpoint |
| --host_mapping_file | path to json output from v1/computers api endpoint |
| --api_key | api key |
| --api_secret | api secret |



# Output

Csv file with the following columns:

| column | description |
| --- | --- |
| hostname | hostname of the endpoint |
| guid | unique endpoint identifier |
| scan_started | Earliest time in the dataset where we detected the endpoint began a scan | 
| scan_finished | Completion time of the scan |
| scan_failed | Time reported of a scan failure |
| detection_from_scan | If the agent reported that the scan caused a detection |
| detections | These are detections within the dataset where timestamp > start_time (and group) passed into the script. **THESE MAY NOT CORRESPOND TO A DETECTION FROM A SCAN** |

# Usage

For use with [Cisco AMP for Endpoints](https://www.cisco.com/c/en/us/products/security/amp-for-endpoints/index.html).

This script will query the api and generate an aggregate report by hosts for agents with scans or detections.


Get json output from the following api endpoints and store locally.

* api.amp.cisco.com/v1/groups
* api.amp.cisco.com/v1/computers


Run the script

```
ruby scan_report.rb --groups "Audit" --group_mapping_file "groups.json" --host_mapping_file "computers.json" --api_key "6d4sdfsf429" --api_secret="878207c0-e62e-4c95-b76e-fb64ecfb2c72" --start_time "2020-04-28 04:22"
```

Parameters:

| parameter | description |
| --- | --- |
| --groups | A comma seperated list of group names (e.g "Audit, Protect") |
| --start_time | ISO formatted time such as 2020-04-28 04:22 - This should be the window when scans were started to get accurate results |
| --group_mapping_file [optional] | path to json output from v1/groups api endpoint for faster processing |
| --host_mapping_file [optional] | path to json output from v1/computers api endpoint for faster processing |
| --api_key | api key |
| --api_secret | api secret |
| --force_cache_update | Force retrieval of group and host mappings from the api. This will use additional api calls |


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
| unresolved_compromises | the number of unresolved inbox items (compromises) from the AMP portal | 
| inprogress_compromises | the number of inbox items (compromises) that are currently in progress from the AMP portal |


# Caching

In order to avoid making too many calls to the API which will count towards the rate-limit imposed by AMP for Endpoints, the script will try and utilize a mapping file if provided with `--group_mapping_file` and `--host_mapping_file`. These should be simply the json output from `GET v1/groups` and `GET v1/computers` respectively.

However, if the files are not provided manually. The script will attempt to retrieve results from the above api and cache them in the `cache` folder. This allows us to avoid making too many API calls on subsequent script runs (subsequent script runs will only need to retrieve from the `GET v1/events` endpoint).

If hostnames are not being populated in the CSV, you can force a cache update with the `--force_cache_update` flag.
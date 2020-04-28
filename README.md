Usage

Get json output from the following api endpoints and store locally.

* api.amp.cisco.com/v1/groups
* api.amp.cisco.com/v1/computers


The command line 

```
ruby scan_report.rb --groups "Audit" --group_mapping_file "groups.json" --host_mapping_file "computers.json" --api_key "6d460649d31d99b3f429" --api_secret="878207c0-e62e-4c95-b76e-fb64ecfb2c72" --start_time "2020-04-28 04:22"
```
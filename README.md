# JsonInference

Given a bunch of JSON documents that are assumed to be similar, collects
info about common structure.  This can be useful for getting a top-level
overview of a document datastore.

## Example

    report = JsonInference.new_report
    huge_json['docs'].each do |doc|
      report << doc
    end
    puts report.to_s

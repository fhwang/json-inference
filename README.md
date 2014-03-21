# JsonInference

Given a bunch of JSON documents that are assumed to be similar, collects
info about common structure.  This can be useful for getting a top-level
overview of a document datastore.

## Example

Run a report by feeding in JSON hashes, like so:

    report = JsonInference.new_report
    huge_json['docs'].each do |doc|
      report << doc
    end
    puts report.to_s

This will output a report that looks like this:

    JsonInference report: 21 documents
    :root > ._id: 21/21 (100.00%)
      String: 100.00%, 0.00% empty

    :root > ._rev: 21/21 (100.00%)
      String: 100.00%, 0.00% empty

    :root > .author_id: 14/21 (66.67%)
      Fixnum: 100.00%

    :root > .sections: 21/21 (100.00%)
      Array: 100.00%, 0.00% empty
      :root > .sections:nth-child(): 50 children
        Hash: 100.00%
        :root > .sections:nth-child() > .title: 50/50 (100.00%)
          String: 100.00%, 0.00% empty
        :root > .sections:nth-child() > .subhead: 50/50 (100.00%)
          String: 100.00%, 2.00% empty
        :root > .sections:nth-child() > .body: 50/50 (100.00%)
          String: 100.00%, 0.00% empty
        :root > .sections:nth-child() > .permalink: 46/50 (92.00%)
          String: 100.00%, 15.22% empty

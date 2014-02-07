require 'test/unit'
$: << '.'
require 'lib/json-inference'
require 'shoulda-context'

class JsonInferenceTestCase < Test::Unit::TestCase
  context "no depth, only strings" do
    setup do
      report = JsonInference.new_report
      report << {foo: 'one'}
      report << {foo: 'two', bar: 'ONE'}
      report << {foo: 'three', baz: 'won'}
      @string = report.to_s
    end

    should "count selectors as part of the total" do
      assert_match(/:root > .foo/, @string)
      assert_match(/3\/3 \(100.00%\)/, @string)
    end

    should "count classes per selector" do
      assert_match(/String: 100.00%/, @string)
    end

    should "sort report by selector" do
      assert_match(/bar.*baz.*foo/m, @string)
    end
  end

  context "no depth, date fields" do
    setup do
      report = JsonInference.new_report
      report << {created_at: '2013-08-21T20:50:16.921Z'}
      report << {created_at: '2013-08-21T20:50:16.555Z'}
      @string = report.to_s
    end

    should "recognize date fields based on format" do
      assert_match(/Date: 100.00%/, @string)
    end
  end

  context "no depth, boolean fields" do
    setup do
      report = JsonInference.new_report
      report << {featured: true}
      report << {featured: false}
      @string = report.to_s
    end

    should "group boolean fields" do
      assert_match(/Boolean: 100.00%/, @string)
    end
  end

  context "hash with uniform keys" do
    setup do
      report = JsonInference.new_report
      report << {embedded: {title: 'title', position: 1}}
      report << {embedded: {title: 'title two', position: 2}}
      @string = report.to_s
    end

    should "show full selectors" do
      assert_match(/:root > .embedded > .title/, @string)
      assert_match(/2\/2 \(100.00%\)/, @string)
    end

    should "count classes per selector" do
      assert_match(/String: 100.00%/, @string)
    end

    should "sort report by selector" do
      assert_match(/embedded.*position/m, @string)
    end
    
    should "display count for the overall hash too" do
      assert_match(/:root > .embedded: 2\/2 \(100.00%\)/, @string)
    end
  end

  context "hash with inconsistent keys" do
    setup do
      report = JsonInference.new_report
      report << {embedded: {title: 'title'}}
      report << {embedded: {}}
      @string = report.to_s
    end

    should "calculate percentages related to occurrences of the field" do
      assert_match(/String: 100.00%/, @string)
    end
  end

  context "field that is sometimes a hash and sometimes not" do
    setup do
      report = JsonInference.new_report
      report << {embedded: {title: 'title'}}
      report << {embedded: "what's this doing here"}
      @string = report.to_s
    end

    should "display all top-level classes" do
      assert_match(/Hash: 50.00%/, @string)
      assert_match(/String: 50.00%/, @string)
    end

    should "display sub nodes" do
      assert_match(/:root > .embedded > .title: 1\/2/, @string)
    end
  end

  context "array" do
    setup do
      report = JsonInference.new_report
      report << {items: [1, 2, 3]}
      report << {items: [4, 5, 6]}
      @string = report.to_s
    end

    should "display a different sort of selector" do
      assert_match(/:root > .items:nth-child\(\): 6 children$/, @string)
    end

    should "count types of children" do
      assert_match(/Fixnum: 100.00%/, @string)
    end
  end

  context "array of hashes" do
    setup do
      report = JsonInference.new_report
      report << {items: [{one: 'one', two: 'two'}, {one: 'ONE', two: 'TWO'}]}
      report << {items: [{one: 'won', two: 'too'}, {one: 1, two: 'two'}]}
      @string = report.to_s
    end
    
    should "count elements in each hash" do
      assert_match(/:root > .items:nth-child\(\) > .one: 4\/4 \(100.00%\)$/, @string)
      assert_match(/:root > .items:nth-child\(\) > .two: 4\/4 \(100.00%\)$/, @string)
    end

    should "count value classes in hashes too" do
      assert_match(/String: 75.00%/, @string)
      assert_match(/Fixnum: 25.00%/, @string)
    end
  end
  
  context "empty array" do
    setup do
      report = JsonInference.new_report
      report << {items: []}
      report << {items: []}
      @string = report.to_s
    end
    
    should "display that there are zero children" do
      assert_match(/:root > .items:nth-child\(\): 0 children$/, @string)
    end
  end

  context "field with empty strings" do
    setup do
      report = JsonInference.new_report
      report << {foo: 'one'}
      report << {foo: '', bar: 'ONE'}
      report << {foo: '', baz: 'won'}
      @string = report.to_s
    end

    should "note how likely it is to be empty" do
      assert_match(/String: 100.00%, 66.67% empty/, @string)
    end
  end

  context "field with the same value most of the time" do
    setup do
      report = JsonInference.new_report
      19.times do
        report << {something: true}
      end
      report << {something: false}
      @string = report.to_s
    end

    should "note that the value is almost always the same" do
      assert_match(/Boolean: 100.00%, 95.00% true/, @string)
    end
  end
end

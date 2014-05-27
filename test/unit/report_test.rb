require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ReportTest < Test::Unit::TestCase
  include TestHelper

  context "creating report object" do
    should "create bank statement" do
      report = create_test_report_bank_statement

      assert_equal 'BankStatement', report.report_id
      assert_equal 'BankStatement', report.report_name
      assert_equal 'BankStatement', report.report_type
      assert report.report_titles.is_a? Array
      assert report.report_date.is_a? Date
      assert report.updated_at.is_a? Time

      # body tests
      assert report.body.is_a? Array
      assert report.body.first.is_a? XeroGateway::Content
      report.body.each do |b|
        assert b.date.is_a? Time
        assert_match /description/, b.description
        assert_match /ref/i, b.reference
        assert_match /no/i, b.reconciled
        assert_match /Import/i, b.source
        assert_equal 200.0, b.amount
        assert_equal 200.0, b.balance
      end
    end
  end
end

require_relative '../../test_helper.rb'

class ReportRowTest < Test::Unit::TestCase

  context "with a sample row" do
    setup do
      @row = XeroGateway::Report::Row.new(
        ["Account",     "Debit", "Credit"],
        ["Sales (200)",  560_00,  0],
        "Bank Accounts"
      )
    end

    should "be able to access using the deprecated column_n API" do
      ActiveSupport::Deprecation.silence do
        assert_equal @row.column_1, "Sales (200)"
        assert_equal @row.column_3, 0

        assert @row.respond_to?(:column_1)
      end
    end

    should "be able to access using an underscored column name" do
      assert_equal @row.account, "Sales (200)"
      assert @row.respond_to?(:account)
    end

    should "be able to access using an array index" do
      assert_equal @row[0], "Sales (200)"
      assert_equal @row[1], 560_00
    end

    should "be able to access using a string index" do
      assert_equal @row["Account"], "Sales (200)"
      assert_equal @row["Debit"],    560_00
    end

    should "be able to access using a symbol index" do
      assert_equal @row[:account], "Sales (200)"
      assert_equal @row[:debit],    560_00
    end

  end

end
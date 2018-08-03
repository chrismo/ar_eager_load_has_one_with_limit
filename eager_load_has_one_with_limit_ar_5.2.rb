require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'activerecord', '~> 5.2.0'
  gem 'sqlite3'
end

require_relative 'core'

describe "eager loading has_one association" do
  let(:texas) { Client.first }
  let(:maine) { Client.last }

  it "without explicit limit" do
    orders = Client.includes(:recent_order).map(&:recent_order)
    assert_row(orders.first, {client_id: texas.id, amount: 46})
    assert_row(orders.last, {client_id: maine.id, amount: 120})
  end

  it "with explicit limit" do
    orders = Client.includes(:recent_order_with_limit).map(&:recent_order_with_limit)
    orders.first.must_equal nil
    assert_row(orders.last, {client_id: maine.id, amount: 120})
  end

  def assert_row(row, values)
    case row
    when Hash
      values.each_pair { |col, value| row[col.to_s].must_equal value }
    else
      values.each_pair { |col, value| row.send(col).must_equal value }
    end
  end
end


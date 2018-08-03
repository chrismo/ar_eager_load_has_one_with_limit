require 'active_record'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

class Client < ActiveRecord::Base
  has_one :address
  has_many :orders

  has_one :recent_order, -> { order('created_at desc') }, class_name: 'Order'
  has_one :recent_order_with_limit, -> { order('created_at desc').limit(1) }, class_name: 'Order'

  connection.create_table table_name, :force => true do |t|
    t.string :name
    t.integer :orders_count
  end
end

class Address < ActiveRecord::Base
  belongs_to :client

  connection.create_table table_name, :force => true do |t|
    t.integer :client_id
    t.string :street
    t.string :state
  end
end

class Order < ActiveRecord::Base
  belongs_to :client

  connection.create_table table_name, :force => true do |t|
    t.integer :client_id
    t.decimal :amount
    t.string :status
    t.timestamps
  end
end

puts ActiveRecord.gem_version

[Client, Address, Order].each { |ar| ar.delete_all }

ActiveRecord::Base.logger = nil

@texas = Client.create!(name: "Texas Person")
@maine = Client.create!(name: "Maine Person")

Address.create!(street: "123 Street Ave.", state: "TX", client: @texas)
Address.create!(street: "456 Main Street", state: "ME", client: @maine)

Order.create!(client: @texas, status: "paid", amount: 30.00)
Order.create!(client: @texas, status: "pending", amount: 46.00)
Order.create!(client: @maine, status: "refunded", amount: 30.00)
Order.create!(client: @maine, status: "pending", amount: 120.00)

ActiveRecord::Base.logger = Logger.new(STDERR)

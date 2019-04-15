class AddDeliveryStatsToEndpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :endpoints, :last_delivery_status, :string
    add_column :endpoints, :last_delivery_time, :timestamp
    add_column :endpoints, :first_failure_time, :timestamp
  end
end

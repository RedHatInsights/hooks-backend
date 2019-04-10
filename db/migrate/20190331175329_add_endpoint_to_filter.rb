class AddEndpointToFilter < ActiveRecord::Migration[5.2]
  def change
    add_reference :filters, :endpoint, foreign_key: true, null: false
  end
end

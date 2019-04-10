class MakeEndpointNameUnique < ActiveRecord::Migration[5.2]
  def change
    change_table :endpoints do |t|
      t.index [:name, :account_id], :unique => true
    end
  end
end

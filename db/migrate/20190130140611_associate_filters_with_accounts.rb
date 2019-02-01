class AssociateFiltersWithAccounts < ActiveRecord::Migration[5.2]
  def change
    change_table :filters do |t|
      t.uuid :account_id, :null => false
      t.foreign_key :accounts
    end
  end
end

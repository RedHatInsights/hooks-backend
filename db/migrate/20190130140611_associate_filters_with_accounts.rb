class AssociateFiltersWithAccounts < ActiveRecord::Migration[5.2]
  def change
    change_table :filters do |t|
      t.references :account, :null => false
    end
  end
end

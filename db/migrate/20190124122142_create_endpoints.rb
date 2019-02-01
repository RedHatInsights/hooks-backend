class CreateEndpoints < ActiveRecord::Migration[5.2]
  def change
    create_table :endpoints do |t|
      t.string :name, :null => false
      t.string :url, :null => false
      t.string :type, :null => false
      t.boolean :active, :default => true
      t.json :data
      t.references :account, :null => false

      t.timestamps
    end
  end
end

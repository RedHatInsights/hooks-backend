class CreateApps < ActiveRecord::Migration[5.2]
  def change
    create_table :apps do |t|
      t.string :name, :null => false

      t.timestamps

      t.index :name, :unique => true
    end
  end
end

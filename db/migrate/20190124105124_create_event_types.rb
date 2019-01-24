class CreateEventTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :event_types do |t|
      t.string :name, :null => false
      t.references :app, :null => false

      t.timestamps

      t.index [:name, :app_id], :unique => true
    end
  end
end

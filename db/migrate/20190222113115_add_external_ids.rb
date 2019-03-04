class AddExternalIds < ActiveRecord::Migration[5.2]
  def change
    change_table :event_types do |t|
      t.string :external_id, :null => false
      t.string :title, :null => false
      t.index [:external_id, :app_id], :unique => true
    end

    change_table :apps do |t|
      t.string :title, :null => false
    end
  end
end

class AddLevels < ActiveRecord::Migration[5.2]
  def up
    create_table :levels do |t|
      t.string :title, :null => false
      t.string :external_id, :null => false
      t.references :event_type

      t.index [:external_id, :event_type_id], :unique => true
    end

    drop_table :severity_filters

    create_table :level_filters do |t|
      t.references :level, :null => false
      t.references :filter, :null => false
      t.index [:level_id, :filter_id]
    end
  end
end

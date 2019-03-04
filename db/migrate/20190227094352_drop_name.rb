class DropName < ActiveRecord::Migration[5.2]
  def change
    remove_column :event_types, :name
  end
end

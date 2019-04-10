class DropEndpointFiltersTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :endpoint_filters do |t|
      t.references :endpoint, :null => false
      t.references :filter, :null => false
      t.index ['endpoint_id', 'filter_id']
    end
  end
end

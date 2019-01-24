class CreateFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :filters do |t|
      t.timestamps
    end

    generate_join_table :app, :filter
    generate_join_table :endpoint, :filter
    generate_join_table :event_type, :filter

    create_table :severity_filters do |t|
      t.string :severity, :null => false
      t.references :filter, :null => false
    end
  end

  private

  def generate_join_table(*tables)
    create_table("#{tables.join('_')}s") do |t|
      tables.each do |table_name|
        t.references table_name, :null => false
      end
      t.index tables.map { |table| "#{table}_id" }
    end
  end
end

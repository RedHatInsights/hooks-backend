# frozen_string_literal: true

class AddIndexToAccounts < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      t.index :account_number, :unique => true
    end
  end
end

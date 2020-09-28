class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string  :name
      t.integer :number
      t.integer :balance, default: 1000
    end
  end
end

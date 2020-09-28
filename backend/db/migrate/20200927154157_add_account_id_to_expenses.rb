class AddAccountIdToExpenses < ActiveRecord::Migration[6.0]
  def change
    add_reference :expenses, :account, foreign_key: true
  end
end

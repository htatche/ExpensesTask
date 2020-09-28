class Account < ApplicationRecord
  validates :name, :number, :balance, presence: true
  validates :balance, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  has_many :expenses, dependent: :destroy

  def update_balance
    update!(balance: self.class.balance_default - expenses.sum(:amount))
  end

  def self.balance_default
    @balance_default ||= Account.column_defaults.fetch('balance')
  end
end

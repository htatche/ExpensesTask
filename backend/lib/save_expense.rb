class SaveExpense
  def initialize(expense)
    @expense = expense
    @account = expense.account
  end

  def self.call(expense)
    new(expense).call
  end

  def call
    ActiveRecord::Base.transaction do
      @expense.save!
      @account.update_balance
    end
  end
end

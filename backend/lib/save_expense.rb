class SaveExpense
  def self.call(expense, current_account = nil)
    new(expense, current_account).call
  end

  def initialize(expense, current_account)
    @expense = expense
    @account = expense.account
    @current_account = current_account
  end

  def call
    ActiveRecord::Base.transaction do
      @expense.save!
      @account.update_balance
      @current_account.update_balance if @current_account
    end
  end
end

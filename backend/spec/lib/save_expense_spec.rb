require 'save_expense'

RSpec.describe SaveExpense do
  let(:account) { Account.create(name: 'account1', number: 1234) }
  let(:expense) { Expense.new(amount: 1000, date: '2020-09-28', description: 'expense1', account: account) }

  describe '.call' do
    context 'when expense will overdrawn the account' do
      before do
        expense.amount = Account.balance_default + 1
      end

      it 'raises a validation error' do
        expect { described_class.call(expense) }.to raise_error(
          ActiveRecord::RecordInvalid,
          'Validation failed: Balance Account cannot be overdrawn'
        )
      end
    end

    it 'saves the expense' do
      expect { described_class.call(expense) }.to change{ Expense.count }.from(0).to(1)
    end
  end
end

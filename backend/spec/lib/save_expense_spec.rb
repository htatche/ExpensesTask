require 'save_expense'

RSpec.describe SaveExpense do
  let(:account) { Account.create(name: 'account1', number: 1234) }
  let(:expense) { Expense.new(amount: 1000, date: '2020-09-28', description: 'expense1', account: account) }

  describe '.call' do
    it 'saves the expense' do
      expect { described_class.call(expense) }.to change{ Expense.count }.from(0).to(1)
    end

    it 'updates the account balance' do
      expect { described_class.call(expense) }.to change{ account.balance }.from(Account.balance_default).to(0)
    end

    context 'when the account was changed' do
      let(:account) { Account.create(name: 'account1', number: 1234, expenses: [expense]) }
      let(:expense) { Expense.create(amount: 1000, date: '2020-09-28', description: 'expense1') }
      let(:account2) { Account.create(name: 'account2', number: 5678) }

      before do
        account.update_balance

        expense.account = account2
      end

      it 'updates the balance for the old account' do
        expect { described_class.call(expense, account) }.to change{ account.balance }.from(0).to(Account.balance_default)
      end

      it 'updates the balance for the new account' do
        expect { described_class.call(expense) }.to change{ account2.balance }.from(Account.balance_default).to(0)
      end
    end

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
  end
end

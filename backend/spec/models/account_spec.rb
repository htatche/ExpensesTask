RSpec.describe Account do
  subject { Account.create(name: 'account1', number: 1234, expenses: [expense]) }

  let(:expense) { Expense.new(amount: 1000, date: '2020-09-28', description: 'expense1') }

  describe '#update_balance' do
    it 'updates the balance' do
      expect { subject.update_balance }.to change{ subject.balance }.from(Account.balance_default).to(0)
    end
  end
end

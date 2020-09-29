RSpec.describe ExpensesController do
  let(:account) { Account.create(name: 'account1', number: 1234) }
  let(:expense_params) { { expense: { account_id: account.id, amount: 100, date: Date.today, description: 'desc' } } }

  describe 'GET #index' do
    let!(:expense1) { Expense.create(account: account, amount: 100, date: Date.today, description: 'desc') }
    let!(:expense2) { Expense.create(account: account, amount: 100, date: Date.today, description: 'desc') }

    it 'returns the expenses with their account names' do
      get :index

      body = JSON.parse(response.body)

      expect(body).to contain_exactly(
        expense1.as_json.merge('account' => {'name' => expense1.account.name}),
        expense2.as_json.merge('account' => {'name' => expense2.account.name})
      )
    end
  end

  describe 'GET #show' do
    let!(:expense1) { Expense.create(account: account, amount: 100, date: Date.today, description: 'desc') }

    it 'returns the expenses' do
      get :show, params: { id: expense1.id }

      body = JSON.parse(response.body)

      expect(body).to eq(expense1.as_json)
    end
  end

  describe 'POST #create' do
    it 'returns the created expense' do
      post :create, params: expense_params

      body = JSON.parse(response.body)

      expect(body.keys).to include('id', 'account_id', 'amount', 'date', 'description')
    end
  end

  describe 'PUT #update' do
    let(:expense1) { Expense.create(account: account, amount: 100, date: Date.today, description: 'desc') }
    let(:expense_params) { { expense: { amount: 500 } } }

    it 'returns the updated expense' do
      put :update, params: { id: expense1.id }.merge(expense_params)

      body = JSON.parse(response.body)

      expect(body.keys).to include('id', 'account_id', 'amount', 'date', 'description')
      expect(body.fetch('amount')).to eq 500
    end

    context 'when the amount will overdrawn the account' do
      let(:expense_params) { { expense: { amount: Account.balance_default + 1 } } }

      it 'returns a validation error' do
        put :update, params: { id: expense1.id }.merge(expense_params)

        body = JSON.parse(response.body)

        expect(body.fetch('balance')).to contain_exactly('Account cannot be overdrawn')
        expect(response).to_not be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:expense1) { Expense.create(account: account, amount: 100, date: Date.today, description: 'desc') }

    it 'is successful' do
      delete :destroy, params: { id: expense1.id }

      expect(response).to be_successful
    end

    it 'updates the account balance' do
      account.update_balance

      expect{
        delete :destroy, params: { id: expense1.id }
      }.to change{ account.reload.balance }.from(900).to(1000)
    end
  end
end

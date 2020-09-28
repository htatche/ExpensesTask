RSpec.describe AccountsController do
  let(:account_params) { { account: { name: 'account1', number: 1234 } } }

  describe 'GET #index' do
    let!(:account1) { Account.create(name: 'account1', number: 1234) }
    let!(:account2) { Account.create(name: 'account2', number: 5678) }

    it 'returns the accounts' do
      get :index

      body = JSON.parse(response.body)

      expect(body).to contain_exactly(account1.as_json, account2.as_json)
    end
  end

  describe 'POST #create' do
    it 'returns the created account' do
      post :create, params: account_params

      body = JSON.parse(response.body)

      expect(body.keys).to include('id', 'name', 'number', 'balance')
    end
  end

  describe 'PUT #update' do
    let(:account) { Account.create(name: 'account1', number: 1234) }
    let(:account_params) { { account: { number: 5678 } } }

    it 'returns the updated account' do
      put :update, params: { id: account.id }.merge(account_params)

      body = JSON.parse(response.body)

      expect(body.keys).to include('id', 'name', 'number', 'balance')
      expect(body.fetch('number')).to eq 5678
    end
  end

  describe 'DELETE #destroy' do
    let(:account) { Account.create(name: 'account1', number: 1234) }

    it 'is successful' do
      delete :destroy, params: { id: account.id }

      expect(response).to be_successful
    end
  end
end

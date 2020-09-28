class AccountsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid do |error|
    expense = error.record
    render json: expense.errors, status: :bad_request
  end

  def index
    render json: Account.order(number: :asc)
  end

  def create
    account = Account.new(account_params)

    render json: account if account.save!
  end

  def update
    account = Account.find(params[:id])

    render json: account if account.update!(account_params)
  end

  def destroy
    account = Account.find(params[:id])

    account.destroy!

    head :no_content
  end

  private

  def account_params
    params.require(:account).permit(:name, :number)
  end
end

require 'save_expense'

class ExpensesController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid do |error|
    expense = error.record
    render json: expense.errors, status: :bad_request
  end

  def index
    render json: Expense.order(date: :desc)
  end

  def show
    expense = Expense.find(params[:id])

    render json: expense
  end

  def create
    expense = Expense.new(expense_params)

    SaveExpense.call(expense)

    render json: expense
  end

  def update
    expense = Expense.find(params[:id])
    current_account = expense.account

    expense.assign_attributes(expense_params)

    SaveExpense.call(expense, current_account)

    render json: expense
  end

  def destroy
    expense = Expense.find(params[:id])

    account = expense.account

    account.update_balance if expense.destroy
  end

  private

  def expense_params
    params.require(:expense).permit(:amount, :date, :description, :account_id)
  end
end

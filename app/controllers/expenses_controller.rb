class ExpensesController < ApplicationController
  before_action :require_household
  before_action :set_categories, only: %i[ new create edit update ]
  before_action :set_expense, only: %i[ edit update destroy ]

  def new
    @expense = current_household.expenses.new(spent_on: Date.current, category_id: params[:category_id])
  end

  def create
    @expense = current_household.expenses.new(expense_params)
    @expense.user = current_user
    if @expense.save
      redirect_to root_path, notice: "Added #{helpers.money(@expense.amount)} to #{@expense.category.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @expense.update(expense_params)
      redirect_to root_path, notice: "Expense updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to root_path, notice: "Expense deleted.", status: :see_other
  end

  private

  def set_expense
    @expense = current_household.expenses.find(params[:id])
  end

  def set_categories
    @categories = current_household.categories.ordered
  end

  def expense_params
    params.expect(expense: [ :amount, :category_id, :note, :spent_on ])
  end
end

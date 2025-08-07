defmodule ExpenseTracker.BudgetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExpenseTracker.Budget` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: Faker.Lorem.sentence(),
        monthly_budget: 120.5,
        name: Faker.Food.dish()
      })
      |> ExpenseTracker.Budget.create_category()

    category
  end

  @doc """
  Generate an expense.
  """
  def expense_fixture(attrs \\ %{}) do
    category = Map.get(attrs, :category) || category_fixture()

    {:ok, expense} =
      attrs
      |> Enum.into(%{
        date: ~D[2025-04-13],
        description: Faker.Lorem.word(),
        amount: 120.5,
        notes: Faker.Lorem.sentence(),
        category_id: category.id
      })
      # Prevent passing :category as an unexpected key
      |> Map.delete(:category)
      |> ExpenseTracker.Budget.create_expense()

    # preload :category after creation
    expense = ExpenseTracker.Repo.preload(expense, :category)

    expense
  end
end

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
        description: "some description",
        monthly_budget: "120.5",
        name: "some name"
      })
      |> ExpenseTracker.Budget.create_category()

    category
  end
end

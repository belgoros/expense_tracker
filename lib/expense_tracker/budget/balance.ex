defmodule ExpenseTracker.Budget.Balance do
  @moduledoc """
  A simple read-model representing the monthly budget balance for a category.
  """

  use TypedEctoSchema

  @primary_key false
  typed_embedded_schema do
    field :category_id, :integer
    field :category_name, :string
    field :monthly_budget, :decimal
    field :total_spent, :decimal, default: 0
    field :remaining_budget, :decimal, default: 0
  end
end

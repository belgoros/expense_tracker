defmodule ExpenseTracker.Budget.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @maximum_budget_amount 5_000

  schema "categories" do
    field :name, :string
    field :description, :string
    field :monthly_budget, :decimal
    has_many :expenses, ExpenseTracker.Budget.Expense

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :monthly_budget])
    |> validate_required([:name, :description, :monthly_budget])
    |> validate_number(:monthly_budget,
      greater_than: 0,
      less_than_or_equal_to: @maximum_budget_amount
    )
  end
end

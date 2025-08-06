defmodule ExpenseTracker.Budget.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :date, :date
    field :description, :string
    field :amount, :decimal
    field :notes, :string
    belongs_to :category, ExpenseTracker.Budget.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:description, :amount, :date, :notes, :category_id])
    |> validate_required([:description, :amount, :date, :category_id])
  end
end

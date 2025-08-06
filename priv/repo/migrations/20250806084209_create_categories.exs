defmodule ExpenseTracker.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :string
      add :monthly_budget, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end

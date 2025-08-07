# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExpenseTracker.Repo.insert!(%ExpenseTracker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Seeder do
  alias ExpenseTracker.Repo
  alias ExpenseTracker.Budget
  alias ExpenseTracker.Budget.{Category, Expense}

  def run() do
    Repo.delete_all(Category)

    create_categories()
    |> Enum.each(fn category ->
      create_expense_for(category)
    end)
  end

  defp create_categories do
    for _ <- 1..5 do
      %Category{
        description: Faker.Food.dish(),
        monthly_budget: Enum.random(100..500),
        name: Faker.Commerce.department()
      }
      |> Repo.insert!()
    end
  end

  defp create_expense_for(category) do
    Enum.each(
      1..3,
      fn _ ->
        %Expense{
          category_id: category.id,
          date: Faker.Date.backward(4),
          description: Faker.Commerce.En.product_name(),
          amount: Enum.random(2..50),
          notes: Faker.Lorem.sentence()
        }
        |> Repo.insert!()
      end
    )
  end
end

Seeder.run()

defmodule ExpenseTracker.BudgetTest do
  use ExpenseTracker.DataCase

  alias ExpenseTracker.Budget

  alias ExpenseTracker.Budget.{Category, Expense}

  import ExpenseTracker.BudgetFixtures

  describe "categories" do
    @invalid_attrs %{name: nil, description: nil, monthly_budget: nil}
    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Budget.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Budget.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", monthly_budget: 120.5}

      assert {:ok, %Category{} = category} = Budget.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.monthly_budget == Decimal.new("120.5")
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Budget.create_category(@invalid_attrs)
    end

    test "create_category/1 with invalid budget returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Budget.create_category(%{@invalid_attrs | monthly_budget: -1})

      assert {:error, %Ecto.Changeset{}} =
               Budget.create_category(%{@invalid_attrs | monthly_budget: 1_000_000})
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        monthly_budget: 456.7
      }

      assert {:ok, %Category{} = category} = Budget.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.monthly_budget == Decimal.new("456.7")
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Budget.update_category(category, @invalid_attrs)
      assert category == Budget.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Budget.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Budget.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Budget.change_category(category)
    end
  end

  describe "expenses" do
    @invalid_attrs %{date: nil, description: nil, amount: nil}
    test "list_expenses/0 returns all expenses" do
      expense = expense_fixture()
      assert Budget.list_expenses() == [expense]
    end

    test "create_expense/1 with valid data creates an expense" do
      category = category_fixture()

      valid_attrs = %{
        date: ~D[2025-01-01],
        description: "some description",
        amount: 10.0,
        category_id: category.id
      }

      assert {:ok, %Expense{} = expense} = Budget.create_expense(valid_attrs)
      assert expense.date == ~D[2025-01-01]
      assert expense.description == "some description"
      assert expense.amount == Decimal.new("10.0")
    end

    test "create_expense/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Budget.create_expense(@invalid_attrs)
    end
  end

  describe "total spent vs. budget for each category" do
    test "total_spent_by_category/0 displays zero value as total_spent if category has no expenses " do
      category = category_fixture(%{monthly_budget: 100})

      %{
        category: _category,
        monthly_budget: monthly_budget,
        total_spent: total_spent,
        remaining_budget: remaining_budget
      } = Budget.total_spent_by_category() |> hd()

      assert Decimal.equal?(category.monthly_budget, monthly_budget)
      assert Decimal.equal?(remaining_budget, category.monthly_budget)
      assert Decimal.equal?(total_spent, Decimal.new("0"))
    end

    test "total_spent_by_category/0 displays correct values if expenses present" do
      category = category_fixture(%{monthly_budget: 100})
      expense_fixture(%{category: category, amount: 20})
      expense_fixture(%{category: category, amount: 50})

      %{
        category: _category,
        monthly_budget: monthly_budget,
        total_spent: total_spent,
        remaining_budget: remaining_budget
      } = Budget.total_spent_by_category() |> hd()

      assert Decimal.equal?(category.monthly_budget, monthly_budget)
      assert Decimal.equal?(remaining_budget, Decimal.new("30"))
      assert Decimal.equal?(total_spent, Decimal.new("70"))
    end
  end

  describe "get_category_with_expenses/1" do
    test "it returns a category with its expenses limited to the default value" do
      category = category_fixture(%{monthly_budget: 200})

      for _ <- 1..10 do
        expense_fixture(%{category: category, amount: 10})
      end

      category_with_expenses = Budget.get_category_with_expenses!(category.id)

      assert Enum.count(category_with_expenses.expenses) == 5
    end
  end
end

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
      valid_attrs = %{name: "some name", description: "some description", monthly_budget: "120.5"}

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
        monthly_budget: "456.7"
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
end

defmodule ExpenseTracker.Budget do
  @moduledoc """
  The Budget context.
  """

  import Ecto.Query, warn: false
  alias ExpenseTracker.Repo

  alias ExpenseTracker.Budget.{Category, Expense}

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @doc """
  Creates an expense.

  ## Examples

      iex> create_expense(%{field: value})
      {:ok, %Expense{}}

      iex> create_expense(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expense(attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of expenses with categories preloaded.

  ## Examples

      iex> list_expenses()
      [%Expense{}, ...]

  """
  def list_expenses do
    Repo.all(Expense) |> Repo.preload(:category)
  end

  @doc """
  Returns the list of total spent vs budget for each category
  ## Examples
      iex> total_spent_by_category()
      [
        %{
          category: value,
          monthly_budget: value,
          total_spent: value,
          remaining_budget: value
        },...
      ]
  """
  def total_spent_by_category do
    query =
      from c in Category,
        left_join: e in assoc(c, :expenses),
        group_by: [c.id, c.name, c.monthly_budget],
        select: %{
          category: c.name,
          monthly_budget: c.monthly_budget,
          total_spent: coalesce(sum(e.amount), 0),
          remaining_budget: c.monthly_budget - coalesce(sum(e.amount), 0)
        }

    Repo.all(query)
  end
end

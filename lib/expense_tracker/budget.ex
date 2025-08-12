defmodule ExpenseTracker.Budget do
  @moduledoc """
  The Budget context.
  """

  import Ecto.Query
  alias ExpenseTracker.Repo
  alias ExpenseTracker.Budget.{Category, Expense}

  @expenses_per_page_limit Application.compile_env(:expense_tracker, [
                             __MODULE__,
                             :expenses_per_page
                           ])

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

  def get_category_with_expenses!(id) do
    Repo.get!(Category, id)
    |> Repo.preload(expenses: limited_expenses_query(@expenses_per_page_limit))
  end

  def limited_expenses_query(limit) do
    from e in Expense,
      limit: ^limit,
      order_by: [desc: e.inserted_at]
  end

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
    category_id = attrs["category_id"] || attrs[:category_id]
    amount = attrs["amount"] || attrs[:amount]

    # Handle missing category_id
    if is_nil(category_id) do
      changeset =
        Expense.changeset(%Expense{}, attrs)
        |> Ecto.Changeset.add_error(:category_id, "can't be blank")

      {:error, changeset}
    else
      category = Repo.get(Category, category_id)

      # Handle non-existent category
      if is_nil(category) do
        changeset =
          Expense.changeset(%Expense{}, attrs)
          |> Ecto.Changeset.add_error(:category_id, "does not exist")

        {:error, changeset}
      else
        # Sum existing expenses for this category
        total_spent =
          from(e in Expense,
            where: e.category_id == ^category_id,
            select: coalesce(sum(e.amount), 0)
          )
          |> Repo.one()

        # Convert all to Decimal for safe arithmetic
        new_total = Decimal.add(total_spent, Decimal.new(amount))

        if Decimal.compare(new_total, category.monthly_budget) == :gt do
          changeset =
            Expense.changeset(%Expense{}, attrs)
            |> Ecto.Changeset.add_error(:amount, "would exceed the category's monthly budget")

          {:error, changeset}
        else
          %Expense{}
          |> Expense.changeset(attrs)
          |> Repo.insert()
        end
      end
    end
  end

  @doc """
  Updates an expense.

  ## Examples

      iex> update_expense(expense, %{field: new_value})
      {:ok, %Expense{}}

      iex> update_expense(expense, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
    |> preload_category()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense changes.

  ## Examples

      iex> change_expense(expense)
      %Ecto.Changeset{data: %Expense{}}

  """
  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
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
          id: value
          name: value,
          monthly_budget: value,
          total_spent: value,
          remaining_budget: value
        },...
      ]
  """
  def total_spent_by_category do
    from(c in Category,
      left_join: e in assoc(c, :expenses),
      group_by: [c.id, c.name, c.monthly_budget],
      select: %{
        id: c.id,
        name: c.name,
        description: c.description,
        monthly_budget: c.monthly_budget,
        total_spent: coalesce(sum(e.amount), 0),
        remaining_budget: c.monthly_budget - coalesce(sum(e.amount), 0)
      }
    )
    |> Repo.all()
  end

  @doc """
  Deletes an expense.

  ## Examples

      iex> delete_expense(expense)
      {:ok, %Expense{}}

      iex> delete_expense(expense)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  defp preload_category({:ok, expense}), do: {:ok, Repo.preload(expense, :category)}
  defp preload_category(error), do: error
end

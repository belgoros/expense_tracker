defmodule ExpenseTrackerWeb.CategoryLive.Show do
  alias ExpenseTracker.Budget.Expense
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Budget

  @impl true
  def mount(%{"category_id" => id} = params, _session, socket) do
    category = Budget.get_category_with_expenses!(id)

    if category do
      {:ok,
       assign(socket,
         category: category,
         page_title: category.name
       )
       |> apply_action(params)}
    else
      socket =
        socket
        |> put_flash(:error, "Category not found")
        |> redirect(to: ~p"/categories")

      {:ok, socket}
    end
  end

  def mount(_invalid_id, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "Category not found")
      |> redirect(to: ~p"/categories")

    {:ok, socket}
  end

  def apply_action(%{assigns: %{live_action: :edit_expense}} = socket, %{
        "expense_id" => expense_id
      }) do
    expense = Enum.find(socket.assigns.category.expenses, &(&1.id == expense_id))

    if expense do
      assign(socket, expense: expense)
    else
      socket
      |> put_flash(:error, "Expense not found")
      |> redirect(to: ~p"/categories/#{socket.assigns.category}")
    end
  end

  def apply_action(socket, _), do: socket

  @impl true
  def handle_event("delete_expense", %{"id" => expense_id}, socket) do
    expense =
      Enum.find(socket.assigns.category.expenses, &(&1.id == String.to_integer(expense_id)))

    if expense do
      case Budget.delete_expense(expense) do
        {:ok, _} ->
          socket =
            socket
            |> put_flash(:info, "Expense deleted")
            |> push_navigate(to: ~p"/categories/#{socket.assigns.category.id}", replace: true)

          {:noreply, socket}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to delete expense")}
      end
    else
      {:noreply, put_flash(socket, :error, "Expense not found")}
    end
  end

  defp default_expense do
    %Expense{
      date: Date.utc_today(),
      amount: 1.0
    }
  end
end

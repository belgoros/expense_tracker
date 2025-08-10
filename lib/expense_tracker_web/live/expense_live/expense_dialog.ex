defmodule ExpenseTrackerWeb.ExpenseLive.ExpenseDialog do
  use ExpenseTrackerWeb, :live_component

  alias ExpenseTracker.Budget

  @impl true
  def update(assigns, socket) do
    changeset =
      Budget.change_expense(assigns.expense, %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    changeset =
      socket.assigns.expense
      |> Budget.change_expense(expense_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"expense" => expense_params}, socket) do
    save_expense(socket, socket.assigns.action, expense_params)
  end

  defp save_expense(socket, :new_expense, expense_params) do
    category = socket.assigns.category

    expense_params =
      Map.put(expense_params, "category_id", category.id)

    case Budget.create_expense(expense_params) do
      {:ok, _expense} ->
        socket =
          socket
          |> put_flash(:info, "Expense created")
          |> push_navigate(to: ~p"/categories/#{category}", replace: true)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp save_expense(socket, :edit_expense, expense_params) do
    category = socket.assigns.category

    expense_params =
      Map.put(expense_params, "category_id", category.id)

    case Budget.update_expense(socket.assigns.expense, expense_params) do
      {:ok, _expense} ->
        socket =
          socket
          |> put_flash(:info, "Expense updated")
          |> push_navigate(to: ~p"/categories/#{category}", replace: true)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset, as: "expense"))
  end
end

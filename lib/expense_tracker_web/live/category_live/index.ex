defmodule ExpenseTrackerWeb.CategoryLive.Index do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Budget
  alias ExpenseTracker.Budget.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :categories, Budget.list_categories())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Budget.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({ExpenseTrackerWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Budget.get_category!(id)
    {:ok, _} = Budget.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end
end

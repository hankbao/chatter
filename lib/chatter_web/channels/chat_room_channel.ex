defmodule ChatterWeb.ChatRoomChannel do
  use ChatterWeb, :channel

  @impl true
  def join("chat_room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat_room:lobby).
  @impl true
  def handle_in("new_message", payload, socket) do
    spawn(fn ->
      Chatter.Message.changeset(%Chatter.Message{}, payload)
      |> Chatter.Repo.insert()
    end)

    broadcast(socket, "new_message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    Chatter.Message.recent_messages()
    |> Enum.each(fn msg -> push(socket, "new_message", format_msg(msg)) end)

    {:noreply, socket}
  end

  defp format_msg(msg) do
    %{
      name: msg.name,
      message: msg.message
    }
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

defmodule Flightex.Bookings.Agent do
  use Agent

  alias Flightex.Bookings.Booking

  # coveralls-ignore-start
  def start_link(_initial_state) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end
  # coveralls-ignore-stop

  def save(%Booking{} = booking) do
    Agent.update(__MODULE__, &update_state(&1, booking))
    {:ok, booking.id}
  end

  def get(uuid), do: Agent.get(__MODULE__, &get_booking(&1, uuid))

  def get_all, do: {:ok, Agent.get(__MODULE__, & &1)}

  defp update_state(state, %Booking{id: uuid} = booking), do: Map.put(state, uuid, booking)

  defp get_booking(state, uuid) do
    case Map.get(state, uuid) do
      nil -> {:error, "Booking not found!"}
      booking -> {:ok, booking}
    end
  end
end

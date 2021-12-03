defmodule Flightex.Bookings.AgentTest do
  use ExUnit.Case

  import Flightex.Factory

  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking

  describe "save/1" do
    setup do
      BookingAgent.start_link(%{})

      :ok
    end

    test "when the param are valid, return a booking uuid" do
      response =
        :booking
        |> build()
        |> BookingAgent.save()

      {:ok, uuid} = response

      assert response == {:ok, uuid}
    end
  end

  describe "get/1" do
    setup do
      BookingAgent.start_link(%{})

      {:ok, id: UUID.uuid4()}
    end

    test "when the user is found, return a booking", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, uuid} = BookingAgent.save(booking)

      response = BookingAgent.get(uuid)

      expected_response =
        {:ok,
         %Flightex.Bookings.Booking{
           complete_date: ~N[2001-05-07 03:05:00],
           id: id,
           local_destination: "Bananeiras",
           local_origin: "Brasilia",
           user_cpf: "12345678900"
         }}

      assert response == expected_response
    end

    test "when the booking isn't found, returns an error", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, _uuid} = BookingAgent.save(booking)

      response = BookingAgent.get("banana")

      expected_response = {:error, "Booking not found!"}

      assert response == expected_response
    end
  end

  describe "get_all/0" do
    setup do
      BookingAgent.start_link(%{})

      {:ok, id: UUID.uuid4()}
    end

    test "returns the booking list", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, _uuid} = BookingAgent.save(booking)

      {:ok, response} = BookingAgent.get_all()

      response = Map.get(response, id)

      expected_response = %Booking{
        complete_date: ~N[2001-05-07 03:05:00],
        id: id,
        local_destination: "Bananeiras",
        local_origin: "Brasilia",
        user_cpf: "12345678900"
      }

      assert response == expected_response
    end
  end
end

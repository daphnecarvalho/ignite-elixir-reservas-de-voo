defmodule Flightex.Bookings.CreateOrUpdateTest do
  use ExUnit.Case, async: false

  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.CreateOrUpdate, as: CreateOrUpdateBooking
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.CreateOrUpdate, as: CreateOrUpdateUser

  describe "call/1" do
    setup do
      BookingAgent.start_link(%{})
      UserAgent.start_link(%{})

      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      user = CreateOrUpdateUser.call(params)

      {:ok, user: user}
    end

    test "when all params are valid, returns a tuple", %{user: user} do
      params = %{
        complete_date: ~N[2001-05-07 03:05:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: user.cpf
      }

      booking = CreateOrUpdateBooking.call(params)

      {:ok, response} = BookingAgent.get(booking.id)

      expected_response = %Flightex.Bookings.Booking{
        id: response.id,
        complete_date: ~N[2001-05-07 03:05:00],
        local_destination: "Bananeiras",
        local_origin: "Brasilia",
        user_cpf: "12345678900"
      }

      assert response == expected_response
    end

    test "when there is an invalid user, returns an error" do
      params = %{
        complete_date: ~N[2001-05-07 03:05:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: "cpf"
      }

      expected_response = {:error, "User not found!"}

      response = CreateOrUpdateBooking.call(params)

      assert response == expected_response
    end
  end
end

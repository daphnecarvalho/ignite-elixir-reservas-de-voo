defmodule Flightex.Bookings.BookingTest do
  use ExUnit.Case, async: false

  alias Flightex.Bookings.Booking

  describe "build/4" do
    test "when all params are valid, returns a booking" do
      {:ok, response} =
        Booking.build(
          "12345678900",
          ~N[2001-05-07 01:46:20],
          "Brasilia",
          "ilha das bananas"
        )

      expected_response = %Flightex.Bookings.Booking{
        complete_date: ~N[2001-05-07 01:46:20],
        id: response.id,
        local_destination: "ilha das bananas",
        local_origin: "Brasilia",
        user_cpf: "12345678900"
      }

      assert response == expected_response
    end
  end
end

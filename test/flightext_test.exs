defmodule FlightexTest do
  use ExUnit.Case

  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.CreateOrUpdate, as: CreateOrUpdateUser
  alias Flightex.Users.User

  describe "create_or_update_user/1" do
    setup do
      UserAgent.start_link(%{})

      :ok
    end

    test "when all params are valid, return a tuple" do
      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      Flightex.create_or_update_user(params)

      {:ok, response} = UserAgent.get(params.cpf)

      expected_response = %User{
        cpf: "12345678900",
        email: "jp@banana.com",
        id: response.id,
        name: "Jp"
      }

      assert response == expected_response
    end

    test "when CPF is an integer, returns an error" do
      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: 12_345_678_900
      }

      expected_response = {:error, "CPF must be a string!"}

      response = Flightex.create_or_update_user(params)

      assert response == expected_response
    end
  end

  describe "create_or_update_booking/1" do
    setup do
      BookingAgent.start_link(%{})
      UserAgent.start_link(%{})

      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      CreateOrUpdateUser.call(params)

      :ok
    end

    test "when all params are valid, returns a tuple" do
      params = %{
        complete_date: ~N[2001-05-07 03:05:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: "12345678900"
      }

      response = Flightex.create_or_update_booking(params)

      expected_response = %Flightex.Bookings.Booking{
        id: response.id,
        complete_date: ~N[2001-05-07 03:05:00],
        local_destination: "Bananeiras",
        local_origin: "Brasilia",
        user_cpf: "12345678900"
      }

      assert response == expected_response
    end
  end
end

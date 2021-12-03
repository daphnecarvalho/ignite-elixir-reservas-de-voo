defmodule FlightexTest do
  use ExUnit.Case

  import Flightex.Factory

  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.CreateOrUpdate, as: CreateOrUpdateUser
  alias Flightex.Users.User

  describe "get_user/1" do
    setup do
      UserAgent.start_link(%{})

      {:ok, cpf: "12345678900"}
    end

    test "when a CPF is informed, returns the user", %{cpf: cpf} do
      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: cpf
      }

      Flightex.create_or_update_user(params)

      {:ok, response} = Flightex.get_user(cpf)

      expected_response = %User{
        cpf: cpf,
        email: "jp@banana.com",
        id: response.id,
        name: "Jp"
      }

      assert response == expected_response
    end
  end

  describe "get_booking/1" do
    setup do
      Flightex.start_agents()

      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      user = CreateOrUpdateUser.call(params)

      {:ok, user: user}
    end

    test "when a UUID is informed, returns the booking information", %{user: user} do
      params = %{
        complete_date: ~N[2001-05-07 03:05:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: user.cpf
      }

      booking = Flightex.create_or_update_booking(params)

      {:ok, response} = Flightex.get_booking(booking.id)

      expected_response = %Booking{
        complete_date: ~N[2001-05-07 03:05:00],
        id: booking.id,
        local_destination: "Bananeiras",
        local_origin: "Brasilia",
        user_cpf: user.cpf
      }

      assert response == expected_response
    end
  end

  describe "get_all_users/0" do
    setup do
      Flightex.start_agents()

      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      user = CreateOrUpdateUser.call(params)

      {:ok, user: user}
    end

    test "returns all users", %{user: user} do
      {:ok, users} = Flightex.get_all_users()

      response = Map.get(users, user.cpf)

      expected_response = %User{
        cpf: user.cpf,
        email: "jp@banana.com",
        id: user.id,
        name: "Jp"
      }

      assert response == expected_response
    end
  end

  describe "get_all_bookings/0" do
    setup do
      Flightex.start_agents()

      {:ok, id: UUID.uuid4()}
    end

    test "returns all bookings", %{id: id} do
      booking = build(:booking, id: id)
      {:ok, _uuid} = BookingAgent.save(booking)

      {:ok, bookings} = Flightex.get_all_bookings()

      response = Map.get(bookings, id)

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
      Flightex.start_agents()

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

  describe "generate_report/0" do
    setup do
      Flightex.start_agents()
      :ok
    end

    test "create report with all bookings" do
      booking = build(:booking)
      BookingAgent.save(booking)

      Flightex.get_all_bookings()

      Flightex.generate_report()
      response = File.read("report.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 03:05:00\n"}

      assert response == expected_response
    end
  end

  describe "generate_report/1" do
    setup do
      Flightex.start_agents()
      :ok
    end

    test "when a filename is informed, create report with all bookings" do
      booking = build(:booking)
      BookingAgent.save(booking)

      Flightex.get_all_bookings()

      Flightex.generate_report("report_test.csv")
      response = File.read("report_test.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 03:05:00\n"}

      assert response == expected_response
    end
  end

  describe "generate_report/2" do
    setup do
      Flightex.start_agents()
      :ok
    end

    test "when a from date and to date is informed, create report with all bookings in the interval" do
      booking = build(:booking)
      BookingAgent.save(booking)

      Flightex.generate_report(~D[2001-05-01], ~D[2001-05-08])
      response = File.read("report_by_date_interval.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 03:05:00\n"}

      assert response == expected_response
    end
  end

  describe "generate_report/3" do
    setup do
      Flightex.start_agents()
      :ok
    end

    test "when a filename, from date and to date is informed, create report with all bookings in the interval" do
      booking = build(:booking)
      BookingAgent.save(booking)

      Flightex.generate_report(~D[2001-05-01], ~D[2001-05-08], "report_test.csv")
      response = File.read("report_test.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 03:05:00\n"}

      assert response == expected_response
    end
  end
end

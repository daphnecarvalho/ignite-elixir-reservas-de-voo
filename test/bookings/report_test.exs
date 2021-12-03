# Este teste é opcional, mas vale a pena tentar e se desafiar 😉

defmodule Flightex.Bookings.ReportTest do
  use ExUnit.Case

  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Report
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.CreateOrUpdate, as: CreateOrUpdateUser

  describe "generate/1" do
    setup do
      BookingAgent.start_link(%{})
      UserAgent.start_link(%{})

      :ok
    end

    test "when called, return the content" do
      user = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      CreateOrUpdateUser.call(user)

      booking = %{
        complete_date: ~N[2001-05-07 12:00:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: "12345678900"
      }

      Flightex.create_or_update_booking(booking)
      Report.create("report_test.csv")
      response = File.read("report_test.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 12:00:00\n"}

      assert response == expected_response
    end
  end

  describe "create_by_date_interval/3" do
    setup do
      BookingAgent.start_link(%{})
      UserAgent.start_link(%{})

      user = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      CreateOrUpdateUser.call(user)

      booking = %{
        complete_date: ~N[2001-05-07 12:00:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: "12345678900"
      }

      Flightex.create_or_update_booking(booking)

      :ok
    end

    test "when a from date and to date is informed (equal), create report with all bookings in the interval" do
      Report.create_by_date_interval(~D[2001-05-07], ~D[2001-05-07])
      response = File.read("report_by_date_interval.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 12:00:00\n"}

      assert response == expected_response
    end

    test "when a from date is greater than a to date, returns an error" do
      response =
        Report.create_by_date_interval(~D[2011-05-15], ~D[2001-05-07], "report_error.csv")

      expected_response = {:error, "Informed From Date is greater than To Date!"}

      assert response == expected_response
    end
  end
end

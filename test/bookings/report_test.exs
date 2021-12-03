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
      params = %{
        name: "Jp",
        email: "jp@banana.com",
        cpf: "12345678900"
      }

      CreateOrUpdateUser.call(params)

      params = %{
        complete_date: ~N[2001-05-07 12:00:00],
        local_origin: "Brasilia",
        local_destination: "Bananeiras",
        user_cpf: "12345678900"
      }

      Flightex.create_or_update_booking(params)
      Report.create("report_test.csv")
      response = File.read("report_test.csv")

      expected_response = {:ok, "12345678900,Brasilia,Bananeiras,2001-05-07 12:00:00\n"}

      assert response == expected_response
    end
  end
end

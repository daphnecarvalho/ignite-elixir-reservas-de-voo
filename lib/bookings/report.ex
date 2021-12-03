defmodule Flightex.Bookings.Report do
  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking

  def create(filename \\ "report.csv") do
    bookings_list = build_bookings_list()

    File.write(filename, bookings_list)
    {:ok, "Report generated successfully!"}
  end

  def create_by_date_interval(from_date, to_date, filename \\ "report_by_date_interval.csv") do
    case Date.compare(from_date, to_date) do
      :gt -> {:error, "Informed From Date is greater than To Date!"}
      :lt -> generate_report_by_date_interval(from_date, to_date, filename)
      :eq -> generate_report_by_date_interval(from_date, to_date, filename)
    end
  end

  defp generate_report_by_date_interval(from_date, to_date, filename) do
    bookings_list = build_bookings_by_date_interval(from_date, to_date)

    File.write(filename, bookings_list)
    {:ok, "Report generated successfully!"}
  end

  defp build_bookings_by_date_interval(from_date, to_date) do
    {:ok, all} = BookingAgent.get_all()

    all
    |> Map.values()
    |> Enum.filter(fn booking -> Date.compare(booking.complete_date, from_date) in [:gt, :eq] end)
    |> Enum.filter(fn booking -> Date.compare(booking.complete_date, to_date) in [:lt, :eq] end)
    |> Enum.map(fn booking -> booking_string(booking) end)
  end

  # 12345678900,Brasilia,Bananeiras,2001-05-07 03:05:00
  defp build_bookings_list() do
    {:ok, all} = BookingAgent.get_all()

    all
    |> Map.values()
    |> Enum.map(fn booking -> booking_string(booking) end)
  end

  defp booking_string(%Booking{
         user_cpf: user_cpf,
         complete_date: complete_date,
         local_origin: local_origin,
         local_destination: local_destination
       }) do
    date = NaiveDateTime.to_string(complete_date)
    "#{user_cpf},#{local_origin},#{local_destination},#{date}\n"
  end
end

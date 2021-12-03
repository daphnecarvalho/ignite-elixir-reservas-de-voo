defmodule Flightex.Bookings.Report do
  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking

  def create(filename \\ "report.csv") do
    bookings_list = build_bookings_list()

    File.write(filename, bookings_list)
  end

  # 12345678900,Brasilia,Bananeiras,2001-05-07 03:05:00
  defp build_bookings_list() do
    BookingAgent.get_all()
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

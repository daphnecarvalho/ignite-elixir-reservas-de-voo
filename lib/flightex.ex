defmodule Flightex do
  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.CreateOrUpdate, as: CreateOrUpdateBooking
  alias Flightex.Bookings.Report
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.CreateOrUpdate, as: CreateOrUpdateUser

  # Start project as test -> MIX_ENV=test iex -S mix
  # import Flightex.Factory
  # Flightex.start_agents()
  # user = %{name: "Jp", email: "jp@email.com", cpf: "12345678900"}
  # Flightex.create_or_update_user(user)
  # booking = %{complete_date: ~N[2001-05-07 03:05:00], local_origin: "Brasilia", local_destination: "Bananeiras", user_cpf: "12345678900"}
  # Flightex.create_or_update_booking(booking)
  # Flightex.get_all_users()
  # Flightex.get_all_bookings()
  # Flightex.get_user("12345678900")
  # Flightex.get_booking("d57e090a-efaf-4f5b-a5bf-32f03f98030c")
  # Flightex.generate_report(~D[2001-05-01], ~D[2001-05-08])
  def start_agents do
    BookingAgent.start_link(%{})
    UserAgent.start_link(%{})
  end

  defdelegate get_user(cpf), to: UserAgent, as: :get

  defdelegate get_booking(uuid), to: BookingAgent, as: :get

  defdelegate get_all_users(), to: UserAgent, as: :get_all

  defdelegate get_all_bookings(), to: BookingAgent, as: :get_all

  defdelegate create_or_update_user(params), to: CreateOrUpdateUser, as: :call

  defdelegate create_or_update_booking(params), to: CreateOrUpdateBooking, as: :call

  defdelegate generate_report(), to: Report, as: :create

  defdelegate generate_report(filename), to: Report, as: :create

  defdelegate generate_report(from_date, to_date), to: Report, as: :create_by_date_interval

  defdelegate generate_report(from_date, to_date, filename),
    to: Report,
    as: :create_by_date_interval
end

defmodule Flightex.Bookings.CreateOrUpdate do
  alias Flightex.Bookings.Agent, as: BookingAgent
  alias Flightex.Bookings.Booking
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.User

  # Start project as test -> MIX_ENV=test iex -S mix
  # import Flightex.Factory
  # Flightex.Users.Agent.start_link(%{})
  # :user |> build() |> Flightex.Users.CreateOrUpdate.call()
  # Flightex.Bookings.Agent.start_link(%{})
  # {:ok, user} = Flightex.Users.Agent.get("12345678900")
  # :booking |> build() |> Flightex.Bookings.CreateOrUpdate.call()
  # Flightex.Bookings.Agent.get_all()
  def call(%{
        user_cpf: user_cpf,
        complete_date: complete_date,
        local_origin: local_origin,
        local_destination: local_destination
      }) do
    case UserAgent.get(user_cpf) do
      {:ok, user} -> build_booking(user, complete_date, local_origin, local_destination)
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_booking(%User{cpf: cpf}, complete_date, local_origin, local_destination) do
    Booking.build(cpf, complete_date, local_origin, local_destination)
    |> save_booking()
  end

  defp save_booking({:ok, %Booking{} = booking}) do
    BookingAgent.save(booking)
    booking
  end
end

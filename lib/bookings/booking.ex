defmodule Flightex.Bookings.Booking do
  @keys [:id, :user_cpf, :complete_date, :local_origin, :local_destination]
  @enforce_keys @keys
  defstruct @keys

  def build(
        user_cpf,
        %NaiveDateTime{} = complete_date,
        local_origin,
        local_destination
      ) do
    {:ok,
     %__MODULE__{
       id: UUID.uuid4(),
       user_cpf: user_cpf,
       complete_date: complete_date,
       local_origin: local_origin,
       local_destination: local_destination
     }}
  end

  def build(_user_uuid, _complete_date, _local_origin, _local_destination),
    do: {:error, "Invalid parameters!"}
end

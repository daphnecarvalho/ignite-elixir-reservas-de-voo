defmodule Flightex.Users.CreateOrUpdate do
  alias Flightex.Users.Agent, as: UserAgent
  alias Flightex.Users.User

  # Start project as test -> MIX_ENV=test iex -S mix
  # import Flightex.Factory
  # Flightex.Users.Agent.start_link(%{})
  # :user |> build() |> Flightex.Users.CreateOrUpdate.call()
  # Flightex.Users.Agent.get_all()
  def call(%{name: name, email: email, cpf: cpf}) do
    User.build(name, email, cpf)
    |> save_user()
  end

  defp save_user({:ok, %User{} = user}) do
    UserAgent.save(user)
    user
  end

  defp save_user({:error, _reason} = error), do: error
end

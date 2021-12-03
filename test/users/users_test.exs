defmodule Flightex.Users.UserTest do
  use ExUnit.Case

  alias Flightex.Users.User

  import Flightex.Factory

  describe "build/3" do
    test "when all params are valid, returns the user" do
      {:ok, response} =
        User.build(
          "Jp",
          "jp@banana.com",
          "12345678900"
        )

      expected_response = build(:user, id: response.id)

      assert response == expected_response
    end

    test "when cpf is a integer, returns an error" do
      response =
        User.build(
          "Jp",
          "jp@banana.com",
          112_250_055
        )

      expected_response = {:error, "CPF must be a string!"}

      assert response == expected_response
    end
  end
end

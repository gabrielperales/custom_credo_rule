defmodule Credo.Check.Readability.PreferStructMatchingTest do
  use Credo.Test.Case

  alias Credo.Check.Readability.PreferStructMatching

  describe "PreferStructMatching" do
    test "it should report an issue when pattern matching a parameter using a map with atom keys" do
      """
        def get_role(%{role: role}) do
          role
        end
      """
      |> to_source_file()
      |> run_check(PreferStructMatching)
      |> assert_issue()
    end
  end
end

defmodule Card.Game.HelperTest do
  use ExUnit.Case
  alias Raw.Game.Helper

  test "full_house_straight" do
    assert Helper.full_house_check([2, 2, 2, 1]) == {:ok, {:full_house, 1, 1}}
    assert Helper.full_house_check([2, 2, 2]) == {:ok, {:full_house, 1, 0}}
    assert Helper.full_house_check([2, 2, 2, 3, 3, 3, 4, 4, 7, 7]) == {:ok, {:full_house, 2, 2}}
    assert Helper.full_house_check([2, 2, 2, 3, 3, 3, 4, 7]) == {:ok, {:full_house, 2, 1}}
  end

  test "full house attach pair" do
    assert Helper.full_house_check([2, 2, 2, 3, 3, 3, 4, 4]) == {:ok, {:full_house, 2, 1}}
  end
end
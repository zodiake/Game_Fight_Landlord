defmodule Raw.Game.GameRule do
  alias __MODULE__
  @moduledoc false
  defstruct state: :init, play1: :not_set, play2: :not_set, play3: :not_set

  def new(), do: %GameRule{}

end

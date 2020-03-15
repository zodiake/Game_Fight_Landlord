defmodule Raw.Game.GameSupervisor do
  use DynamicSupervisor
  alias Raw.Game.Game

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(guid) do
    spec = %{id: Game, start: {Game, :start_link, [guid]}}
    spec = {Game, guid}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_game(guid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_guid(guid))
  end

  def pid_from_guid(guid) do
    guid
    |> Game.via()
    |> GenServer.whereis()
  end
end

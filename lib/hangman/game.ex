defmodule Hangman.Game do
  defstruct turns_left: 7, game_state: :initializing, letters: []
  alias Hangman.{Dictionary, Game}

  def new_game do
    %Game{letters: Dictionary.random_word() |> String.codepoints()}
  end

  def make_move(game = %Game{game_state: state}, _guess) when state in [:won, :lost] do
    {game, tally(game)}
  end

  def tally(_game) do
    123
  end
end

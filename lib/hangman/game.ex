defmodule Hangman.Game do
  defstruct turns_left: 7, game_state: :initializing, letters: [], used: MapSet.new()
  alias Hangman.{Dictionary, Game}

  def new_game(word) do
    %Game{letters: word |> String.codepoints()}
  end

  def new_game do
    Dictionary.random_word() |> new_game()
  end

  def make_move(game = %Game{game_state: state}, _guess) when state in [:won, :lost] do
    {game, tally(game)}
  end

  def make_move(game, guess) do
    game = accept_move(game, guess, MapSet.member?(game.used, guess))
    {game, tally(game)}
  end

  def accept_move(game, _guess, _already_guessed = true) do
    Map.put(game, :game_state, :already_used)
  end

  def accept_move(game, guess, _already_guessed = false) do
    game
    |> Map.put(:used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  def score_guess(game, _good_guess = true) do
    new_state =
      MapSet.new(game.letters)
      |> MapSet.subset?(game.used)
      |> maybe_won()

    Map.put(game, :game_state, new_state)
  end

  def score_guess(game = %Game{turns_left: 1}, _good_guess = false) do
    game
    |> Map.put(:turns_left, 0)
    |> Map.put(:game_state, :lost)
  end

  def score_guess(game = %Game{turns_left: turns_left}, _good_guess = false) do
    game
    |> Map.put(:turns_left, turns_left - 1)
    |> Map.put(:game_state, :bad_guess)
  end

  def tally(_game) do
    123
  end

  def maybe_won(true) do
    :won
  end

  def maybe_won(_) do
    :good_guess
  end
end

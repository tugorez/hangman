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
    game
  end

  def make_move(game, guess) do
    accept_move(game, guess, MapSet.member?(game.used, guess))
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_guessed(game.used)
    }
  end

  defp accept_move(game, _guess, _already_guessed = true) do
    Map.put(game, :game_state, :already_used)
  end

  defp accept_move(game, guess, _already_guessed = false) do
    game
    |> Map.put(:used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do
    new_state =
      MapSet.new(game.letters)
      |> MapSet.subset?(game.used)
      |> maybe_won()

    Map.put(game, :game_state, new_state)
  end

  defp score_guess(game = %Game{turns_left: 1}, _good_guess = false) do
    game
    |> Map.put(:turns_left, 0)
    |> Map.put(:game_state, :lost)
  end

  defp score_guess(game = %Game{turns_left: turns_left}, _good_guess = false) do
    game
    |> Map.put(:turns_left, turns_left - 1)
    |> Map.put(:game_state, :bad_guess)
  end

  defp reveal_guessed(letters, used) do
    Enum.map(letters, fn letter ->
      if Enum.member?(used, letter), do: letter, else: "_"
    end)
  end

  defp maybe_won(true) do
    :won
  end

  defp maybe_won(_) do
    :good_guess
  end
end

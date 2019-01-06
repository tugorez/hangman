defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Game

  test "new_game return structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "state isn't changed for :won game" do
    game = Game.new_game() |> Map.put(:game_state, :won)
    assert ^game = Game.make_move(game, "x")
  end

  test "state isn't changed for :lost game" do
    game = Game.new_game() |> Map.put(:game_state, :lost)
    assert ^game = Game.make_move(game, "x")
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game() |> Game.make_move("x")
    assert game.game_state != :already_used
  end

  test "second occurrence of letter is already used" do
    game = Game.new_game() |> Game.make_move("x")
    assert game.game_state != :already_used
    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble") |> Game.make_move("w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    initial_state = Game.new_game("wibble")

    moves = [
      {"w", :good_guess},
      {"i", :good_guess},
      {"b", :good_guess},
      {"l", :good_guess},
      {"e", :won}
    ]

    Enum.reduce(moves, initial_state, fn {guess, expected_state}, game ->
      game = Game.make_move(game, guess)
      assert game.game_state == expected_state
      assert game.turns_left == 7
      game
    end)
  end

  test "a bad guess is recognized" do
    game = Game.new_game("wibble") |> Game.make_move("d")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "lost game is recognized" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "a")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
    game = Game.make_move(game, "c")
    assert game.game_state == :bad_guess
    assert game.turns_left == 5
    game = Game.make_move(game, "d")
    assert game.game_state == :bad_guess
    assert game.turns_left == 4
    game = Game.make_move(game, "f")
    assert game.game_state == :bad_guess
    assert game.turns_left == 3
    game = Game.make_move(game, "g")
    assert game.game_state == :bad_guess
    assert game.turns_left == 2
    game = Game.make_move(game, "h")
    assert game.game_state == :bad_guess
    assert game.turns_left == 1
    game = Game.make_move(game, "j")
    assert game.game_state == :lost
    assert game.turns_left == 0
  end
end

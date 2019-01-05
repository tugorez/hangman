defmodule Hangman.Dictionary do
  @words "assets/words.txt"

  def random_word do
    word_list()
    |> Enum.random()
  end

  def word_list do
    @words
    |> File.read!()
    |> String.split()
  end
end

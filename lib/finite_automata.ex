defmodule FiniteAutomata do
  @moduledoc """
  This module implements an algorithm to simulate deterministic and non-deterministic finite automata.
  """

  @doc """
  Validates the input for a given automata according to it's alphabet. If the input is valid, the input is deconstructed into a list of chars and passed to the next_state function, along with the initial state and the transition function. \n
  The next_state function will calculate the next state recursively, based on the transition function and the input given. If the automata gets trapped in a state without a valid transition, it will raise an error. If the input is completely consumed in the recursion, the function will return the final state(s). \n
  After the next_state function call, the result will be evaluated. If the input wasn't accepted, the compose_automata will raise an error. If final states can be reached, they will be compared to the acceptance_states, and if there is an intersection, the function will return an :accepted atom. Otherwise, it will raise another error.
  ## Examples
      iex> FiniteAutomata.compose_automata("abcd", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}], :q0, [:q3])
      {:not_accepted, "Input not valid for automata's alphabet."}
      iex> FiniteAutomata.compose_automata("abc", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}], :q0, [:q3])
      {:not_accepted, "Automata is trapped in a non-acceptance state after consuming the input."}
      iex> FiniteAutomata.compose_automata("abc", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "c", :q2}, {:q2, "b", :q1}, {:q1, "c", :q3}], :q0, [:q3])
      {:not_accepted, "Automata is trapped in a state with no valid transition for the given input."}
      iex> FiniteAutomata.compose_automata("abc", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}], :q0, [:q1])
      {:accepted}

  """
  def compose_automata(input, alphabet, transition_function, initial_state, acceptance_states) do
    if validate_input(input, alphabet) == :invalid do
      {:not_accepted, "Input not valid for automata's alphabet."}
    else
      case next_state(String.graphemes(input), [initial_state], transition_function) do
        :not_accepted -> {:not_accepted, "Automata is trapped in a state with no valid transition for the given input."}
        final_states -> case Enum.filter(final_states, fn x -> Enum.member?(acceptance_states, x) end) do
          [] -> {:not_accepted, "Automata is trapped in a non-acceptance state after consuming the input."}
          _ -> {:accepted}
        end
      end
    end
  end

  @doc """
  Validates input according to automata's alphabet.

  ## Examples

      iex> FiniteAutomata.validate_input("abc", ["a", "b", "c"])
      :valid
      iex> FiniteAutomata.validate_input("abc", ["a", "b", "d"])
      :invalid

  """
  def validate_input(input, alphabet) do
    input_chars = String.graphemes(input)
    case Enum.reject(input_chars, fn x -> Enum.member?(alphabet, x) end) do
      [] -> :valid
      _ -> :invalid
    end
  end

  @doc """
  Calculates the next state for the deconstructed input, following the rules of the transition function. \n
  If no next state can be found, the function returns an :empty atom, that will be evaluated in a :not_accepted return. \n
  If one or more next states can be found at the end of the recursion, the function returns a list with the next state(s).

  ## Examples

      iex> FiniteAutomata.next_state(["a", "b", "c"], [:q0], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q3}])
      [:q3]
      iex> FiniteAutomata.next_state(["a", "b", "c", "b"], [:q0], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}])
      [:q2, :q3]
      iex> FiniteAutomata.next_state(["b"], [:q0], [{:q0, "a", :q1}, {:q1, "b", :q2}])
      :not_accepted

  """
  def next_state(input_chars, current_state, transition_function) do
    if current_state == :empty do
      :not_accepted
    else
      [input | rest] = input_chars
      state_transitions = Enum.filter(transition_function, fn x -> Enum.member?(current_state, elem(x, 0)) end)
      valid_transitions = Enum.filter(state_transitions, fn x -> elem(x, 1) == input or elem(x, 1) == nil end)
      case valid_transitions do
        [] -> next_state(input, :empty, transition_function)
        [{_, _, upcoming_state}] -> case length(rest) do
          0 -> [upcoming_state]
          _ -> next_state(rest, [upcoming_state], transition_function)
        end
        _ -> case length(rest) do
          0 -> Enum.reduce(valid_transitions, [], fn x, acc -> acc ++ [elem(x, 2)] end)
          _ -> next_state(rest, Enum.reduce(valid_transitions, [], fn x, acc -> acc ++ [elem(x, 2)] end), transition_function)
        end
      end
    end
  end
end

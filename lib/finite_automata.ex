defmodule FiniteAutomata do
  @moduledoc """
  This module implements an algorithm to simulate deterministic and non-deterministic finite automata.
  A finite automata is formally represented by a 5-tuple ***<Q, S, D, Q0, F>***, where: \n
    - ***Q*** is a finite set of states.
    - ***S*** is a finite set of symbols, called the alphabet of the automaton.
    - ***D*** is the transition function, that is, `D: Q x S -> Q`.
    - ***Q0*** is the start state, that is, the state of the automaton before any input has been processed, where `Q0 ∈ Q`.
    - ***F*** is a set of states of Q (i.e. F ⊆ Q) called accept states. \n
  Another important concept is the input word, that is a string of symbols `a1,a2,....,an, where ai ∈ S`, that is read by the automaton. The set of all words is denoted by *S\**. \n
  After the consumption of the input by the automaton, it reaches a final state, denoted by *Qn*. A word `w ∈ S*` is accepted by the automaton if `Qn ∈ F`. \n
  The algorithm consists of a initial validation of the input based on the alphabet and a recursive logic to go through the states of the automaton based on the input given, according to the transition function. \n
  The algorithm is built to simulate deterministic and non-deterministic finite automata, including non-deterministic with empty transitions. Is heavily based on the Enum library of Elixir, used to deal with lists.
  """

  @doc """
  Validates the input for a given automata according to it's alphabet. If the input is valid, the input is deconstructed into a list of chars and passed to the next_state function, along with the initial state and the transition function. \n
  The next_state function will calculate the next state recursively, based on the transition function and the input given. If the automata gets trapped in a state without a valid transition, it will raise an error. If the input is completely consumed in the recursion, the function will return the final state(s). \n
  After the next_state function call, the result will be evaluated. If the input wasn't accepted, the compose_automata will raise an error. If final states can be reached, they will be compared to the acceptance_states, and if there is an intersection, the function will return an `:accepted` atom. Otherwise, it will raise another error.

  ## Parameters
    - **input**: The input tape that will be evaluated on the finite automata. Must be a string.
    - **alphabet**: A list of the symbols accepted by the automata. The symbols must be represented in a string form.
    - **transition_function**: A list of tuples representing the rules for the transition function. The form o the tuples is `{:q0, "x", :q1}`, representing the initial state, symbol triggering the transition and the next state.
    - **initial_state**: Atom representing the initial state for the automaton. The convention in the tests is using `:qn, n >=0`.
    - **acceptance_states**: Set of acceptance states. Is a list of atoms, used to compare the result of the input path on the automaton, to check if the input is recognized by the automaton.


  ## Examples
      iex> FiniteAutomata.compose_automata("abcd", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}], :q0, [:q3])
      {:not_accepted, "Input not valid for automaton's alphabet."}

      iex> FiniteAutomata.compose_automata("abc", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}], :q0, [:q3])
      {:not_accepted, "Automaton is trapped in a non-acceptance state after consuming the input."}

      iex> FiniteAutomata.compose_automata("abc", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "c", :q2}, {:q2, "b", :q1}, {:q1, "c", :q3}], :q0, [:q3])
      {:not_accepted, "Automaton is trapped in a state with no valid transition for the given input."}

      iex> FiniteAutomata.compose_automata("abc", ["a", "b", "c"], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}], :q0, [:q1])
      {:accepted}

  """
  def compose_automata(input, alphabet, transition_function, initial_state, acceptance_states) do
    if validate_input(input, alphabet) == :invalid do
      {:not_accepted, "Input not valid for automaton's alphabet."}
    else
      case next_state(String.graphemes(input), [initial_state], transition_function) do
        :trapped -> {:not_accepted, "Automaton is trapped in a state with no valid transition for the given input."}
        final_states -> case Enum.filter(final_states, fn x -> Enum.member?(acceptance_states, x) end) do
          [] -> {:not_accepted, "Automaton is trapped in a non-acceptance state after consuming the input."}
          _ -> {:accepted}
        end
      end
    end
  end

  @doc """
  Validates input according to automata's alphabet. If the input contains a symbol not present on the automaton's alphabet, the function returns an `:invalid` atom. Otherwise, it will return a `:valid` atom.

  ## Parameters
    - **input**: The input tape that will be evaluated on the finite automata. Must be a string.
    - **alphabet**: A list of the symbols accepted by the automata. The symbols must be represented in a string form.

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
  If no next state can be found, the function returns an `:empty` atom, that will be evaluated in a `:trapped` return. \n
  If one or more next states can be found at the end of the recursion, the function returns a list with the next state(s).

  ## Parameters
    - **input_chars**: Input string deconstructed in a list of chars, used to iterate the next_state function to find a path on the automaton.
    - **current_state**: The current state of the automaton. Used as parameter to scroll through the transition function, seeking for transition symbols and next states.
    - **transition_function**: A list of tuples representing the rules for the transition function. The form o the tuples is `{:q0, "x", :q1}`, representing the initial state, symbol triggering the transition and the next state.

  ## Examples

      iex> FiniteAutomata.next_state(["a", "b", "c"], [:q0], [{:q0, "a", :q1}, {:q1, "b", :q2}, {:q2, "c", :q3}])
      [:q3]

      iex> FiniteAutomata.next_state(["a", "b", "c", "b"], [:q0], [{:q0, "a", :q1}, {:q0, nil, :q2}, {:q1, "b", :q2}, {:q2, "c", :q1}, {:q1, "b", :q3}])
      [:q2, :q3]

      iex> FiniteAutomata.next_state(["b"], [:q0], [{:q0, "a", :q1}, {:q1, "b", :q2}])
      :trapped

  """
  def next_state(input_chars, current_state, transition_function) do
    if current_state == :empty do
      :trapped
    else
      [input | rest] = input_chars
			current_state = get_next_nil_in_the_chain(current_state, transition_function)
      state_transitions = Enum.filter(transition_function, fn x -> Enum.member?(current_state, elem(x, 0)) end)
      valid_transitions = Enum.filter(state_transitions, fn x -> elem(x, 1) == input or elem(x, 1) == nil end)
			next_states = Enum.reduce(valid_transitions, [], fn x, acc -> acc ++ [elem(x, 2)] end)
			next_states_linked_by_nil = get_next_nil_in_the_chain(next_states, transition_function)

      case valid_transitions do
        [] -> next_state(input_chars, :empty, transition_function)
        [{_, _, _}] -> case length(rest) do
          0 -> next_states_linked_by_nil
          _ -> next_state(rest, next_states_linked_by_nil, transition_function)
        end
        _ -> case length(rest) do
          0 -> next_states_linked_by_nil
          _ -> next_state(rest, next_states_linked_by_nil, transition_function)
        end
      end
    end
  end
	
	def get_next_nil_in_the_chain(initial_states, transition_function) do
		state_transitions = Enum.filter(transition_function, fn x -> Enum.member?(initial_states, elem(x, 0)) end)
		valid_transitions = Enum.filter(state_transitions, fn x -> elem(x, 1) == nil end)
		final_states = Enum.reduce(valid_transitions, [], fn x, acc -> acc ++ [elem(x, 2)] end)
		final_states = final_states ++ initial_states
		final_states = Enum.uniq(final_states)

		if initial_states == final_states do
			final_states
		else
			get_next_nil_in_the_chain(final_states, transition_function)
		end
	end
	
end

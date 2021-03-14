defmodule FiniteAutomataTest do
  use ExUnit.Case
  doctest FiniteAutomata

  test "Non deterministic automaton with empty loop" do
    nondeterministic_with_empty_loop = [
      {:q0, "a", :q0},
      {:q0, "a", :q1},
      {:q0, "a", :q2},
      {:q0, "b", :q1},
      {:q0, nil, :q0},
      {:q0, nil, :q3},
      {:q3, nil, :q0},
      {:q3, "a", :q4},
      {:q4, "b", :q5},
    ]
    assert FiniteAutomata.compose_automata("ab", ["a", "b"], nondeterministic_with_empty_loop, :q0, [:q5]) == {:accepted}
    assert FiniteAutomata.compose_automata("a", ["a", "b"], nondeterministic_with_empty_loop, :q0, [:q5]) == {:not_accepted, "Automaton is trapped in a non-acceptance state after consuming the input."}
  end
  test "Non deterministic automaton empty acceptance" do
    nondeterministic_with_empty_acceptance = [
      {:q0, nil, :q1},
      {:q0, "a", :q2},
      {:q2, "b", :q3},
      {:q0, nil, :q4},
      {:q0, nil, :q5},
      {:q5, nil, :q5},
    ]
    assert FiniteAutomata.compose_automata("ab", ["a", "b"], nondeterministic_with_empty_acceptance, :q0, [:q5]) == {:accepted}
  end

  test "Non deterministic automaton with empty transition" do
    nondeterministic_with_empty_transition = [
      {:q0, "a", :q1},
      {:q1, nil, :q3},
      {:q1, "b", :q2},
      {:q2, "c", :q3},
      {:q2, nil, :q0},
      {:q3, nil, :q0},
      {:q3, nil, :q4},
      {:q3, "d", :q4},
      {:q1, "a", :q2},
    ]
    assert FiniteAutomata.compose_automata("abcd", ["a", "b", "c", "d"], nondeterministic_with_empty_transition, :q0, [:q4]) == {:accepted}
    assert FiniteAutomata.compose_automata("acd", ["a", "b", "c", "d"], nondeterministic_with_empty_transition, :q0, [:q4]) == {:accepted}
    assert FiniteAutomata.compose_automata("a", ["a", "b", "c", "d"], nondeterministic_with_empty_transition, :q0, [:q4]) == {:accepted}
    assert FiniteAutomata.compose_automata("ac", ["a", "b", "c", "d"], nondeterministic_with_empty_transition, :q0, [:q4]) == {:accepted}
  end

  test "Non deterministic without empty input" do
    non_deterministic_transition = [
      {:q0, "a", :q1},
      {:q0, "a", :q0},
      {:q0, "a", :q2},
      {:q1, "a", :q2},
      {:q2, "b", :q3},
      {:q2, "b", :q0},
      {:q3, "a", :q3},
      {:q3, "b", :q3},
    ]
    assert FiniteAutomata.compose_automata("ab", ["a", "b"], non_deterministic_transition, :q0, [:q3]) == {:accepted}
    assert FiniteAutomata.compose_automata("ba", ["a", "b"], non_deterministic_transition, :q0, [:q3]) == {:not_accepted, "Automaton is trapped in a state with no valid transition for the given input."}
  end

  test "Deterministic automaton" do
    deterministic_transition = [
      {:q0, "a", :q1},
      {:q0, "b", :q0},
      {:q1, "b", :q0},
      {:q1, "a", :q2},
      {:q2, "b", :q3},
      {:q2, "a", :q0},
      {:q3, "a", :q3},
      {:q3, "b", :q3},
    ]
    assert FiniteAutomata.compose_automata("aab", ["a", "b"], deterministic_transition, :q0, [:q3]) == {:accepted}
    assert FiniteAutomata.compose_automata("bbabbaaabaab", ["a", "b"], deterministic_transition, :q0, [:q3]) == {:accepted}
    assert FiniteAutomata.compose_automata("aabc", ["a", "b"], deterministic_transition, :q0, [:q3]) == {:not_accepted, "Input not valid for automaton's alphabet."}
    assert FiniteAutomata.compose_automata("bbabbaaabba", ["a", "b"], deterministic_transition, :q0, [:q3]) == {:not_accepted, "Automaton is trapped in a non-acceptance state after consuming the input."}
  end
end

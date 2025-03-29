defmodule Credo.Check.Readability.PreferStructMatching do
  @moduledoc """
  It will analyze your Elixir codebase, and if it parameters of functions patterm matched by maps with atoms,
  the parameter must be a struct.
  """

  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    param_defaults: [],
    explanations: [
      check: """
      If a function is pattern matching a parameter by a map with atoms, the parameter may be a struct.
      We should try to use struct pattern matching instead of map pattern matching if possible.

      # not preferred
      def get_role(%{role: role}) do
        role
      end

      # preferred
      def get_role(%User{role: role}) do
        role
      end

      # preferred
      def get_role(%User{} = user) do
        user.role
      end
      """,
      params: []
    ]

  @doc false
  @impl true
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:def, meta, [{_fn_name, _meta, fn_args} = ast, _fn_body]}, issues, issue_meta) do
    new_issues =
      fn_args
      |> Enum.flat_map(fn arg -> check_arg_pattern(arg, meta, issue_meta) end)

    {ast, issues ++ new_issues}
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp check_arg_pattern({:%{}, _, fields} = _arg, meta, issue_meta) do
    if Enum.any?(fields, fn {key, _value} -> is_atom(key) end) do
      [issue_for(issue_meta, meta[:line], "direct map pattern with atom keys")]
    else
      []
    end
  end

  defp check_arg_pattern(_, _, _), do: []

  defp issue_for(issue_meta, line_no, trigger) do
    # format_issue/2 is a function provided by Credo.Check to help us format the
    # found issue
    format_issue(issue_meta,
      message: "Pattern match by struct instead of by map if possible",
      line_no: line_no,
      trigger: trigger
    )
  end
end

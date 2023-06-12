defmodule Lenra.ViewsHelper do
  defmacro defview(args \\ quote(do: _), do: block) do
    quote do
      @view true
      def c(unquote(args)) do
        unquote(block)
      end

      def r(params \\ []) do
        %{type: "view", name: Lenra.View.get_id(__MODULE__)}
        |> Lenra.Utils.add_all(params, [:coll, :query, :props])
      end
    end
  end
end

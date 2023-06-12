defmodule Lenra.ViewsHelper do
  defmacro defview(args \\ quote(do: _), do: block) do
    if Module.get_attribute(__CALLER__.module, :dirty),
      do:
        raise("""
        defview is already defined in this module, only one view per module is allowed.
        Consider creating a new module or a submodule :


          def App.Views.Foo do
            use Lenra.View
            defview _params do
              # Your first view
            end

            def Bar do
              use Lenra.View
              defview _params do
                # Your second view
                # Call this view using App.Views.Foo.Bar.r/0
              end
            end
          end
        """)

    Module.put_attribute(__CALLER__.module, :dirty, true)

    quote do
      @view true
      def c(unquote(args)) do
        unquote(block)
      end

      def r(params \\ []) do
        %{type: "view", name: Lenra.View.get_id(__MODULE__)}
        |> Lenra.Utils.add_all(params, [:coll, :query, :props])
      end

      def name do
        Lenra.View.get_id(__MODULE__)
      end
    end
  end
end

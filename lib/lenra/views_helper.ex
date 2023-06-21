defmodule Lenra.ViewsHelper do
  defmacro defview(args \\ nil, do: block) do
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

    IO.inspect(args)

    n_fun =
      case args do
        {:_, _, nil} ->
          quote do
            @view true
            def n(_) do
              n()
            end

            def n() do
              unquote(block)
            end
          end

        _ ->
          quote do
            @view true
            def n(unquote(args)) do
              unquote(block)
            end
          end
      end

    rest =
      quote do
        def r(params \\ []) do
          %{type: "view", name: Lenra.View.get_id(__MODULE__)}
          |> Lenra.Utils.add_all(params, [:coll, :query, :props])
        end

        def name do
          Lenra.View.get_id(__MODULE__)
        end
      end

    [n_fun, rest]
  end
end

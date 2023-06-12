defmodule Lenra.ListenerHelper do
  defmacro deflistener(name, args \\ quote(do: _), do: block) do
    quote do
      @listener true
      def unquote(name)(unquote(args)) do
        unquote(block)
      end

      def unquote(:"#{name}_r")(params \\ []) do
        %{action: Lenra.Listener.get_id(__MODULE__, unquote(name))}
        |> Lenra.Utils.add_all(params, [:props])
      end
    end
  end

  # Not sure about the macro case. defonenvstart ? def_on_env_start ?
  defmacro def_on_env_start(args \\ quote(do: _), do: block) do
    quote do
      @listener "onEnvStart"
      def on_env_start(unquote(args)) do
        unquote(block)
      end
    end
  end

  defmacro def_on_session_start(args \\ quote(do: _), do: block) do
    quote do
      @listener "onSessionStart"
      def on_session_start(unquote(args)) do
        unquote(block)
      end
    end
  end

  defmacro def_on_user_first_join(args \\ quote(do: _), do: block) do
    quote do
      @listener "onUserFirstJoin"
      def on_user_first_join(unquote(args)) do
        unquote(block)
      end
    end
  end
end

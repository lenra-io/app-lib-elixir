defmodule Lenra.ListenerHelper do
  defmacro deflistener(name, args \\ quote(do: _), do: block) do
    quote do
      @listener true
      def unquote(name)(unquote(args)) do
        unquote(block)
      end

      def unquote(:"#{name}_r")(params \\ []) do
        %{type: "listener", listener: Lenra.Listener.get_id(__MODULE__, unquote(name))}
        |> Lenra.Utils.add_all(params, [:props])
      end
    end
  end

  # Not sure about the macro case. defonenvstart ? def_on_env_start ?
  defmacro def_on_env_start(args \\ quote(do: _), do: block) do
    quote do
      @listener true
      def onEnvStart(unquote(args)) do
        unquote(block)
      end
    end
  end

  defmacro def_on_session_start(args \\ quote(do: _), do: block) do
    quote do
      @listener true
      def onSessionStart(unquote(args)) do
        unquote(block)
      end
    end
  end

  defmacro def_on_user_first_join(args \\ quote(do: _), do: block) do
    quote do
      @listener true
      def onUserFirstJoin(unquote(args)) do
        unquote(block)
      end
    end
  end
end

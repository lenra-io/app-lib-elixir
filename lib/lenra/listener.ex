defmodule Lenra.Listener do
  use Lenra.Utils.AnnotationUtils, binding_fun: :__listeners__

  defmacro __using__(_opts) do
    quote do
      @before_compile Lenra.Listener
      @on_definition Lenra.Listener
      @listeners %{}
      import Lenra.ListenerHelper

      def call(fun, args) do
        apply(__MODULE__, fun, [args])
      end

      defoverridable call: 2
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __listeners__() do
        @listeners
      end
    end
  end

  def __on_definition__(env, _kind, fun_name, _args, _guards, _body) do
    id = get_id(env.module, fun_name)
    listeners = Module.get_attribute(env.module, :listeners)

    case Module.delete_attribute(env.module, :listener) do
      false ->
        :ok

      nil ->
        :ok

      true ->
        check_and_save(listeners, id, env.module, fun_name)

      value when is_bitstring(value) ->
        check_and_save(listeners, value, env.module, fun_name)
    end
  end

  defp check_and_save(listeners, id, module, fun_name) do
    with :ok <- Lenra.Utils.AnnotationUtils.check_exists(listeners, id, "listener") do
      Module.put_attribute(
        module,
        :listeners,
        Map.put(listeners, id, %{
          mod: module,
          fun: fun_name
        })
      )
    end
  end

  def get_id(mod_name, fun_name) do
    "#{mod_name}.#{fun_name}" |> String.replace(".", "_")
  end
end

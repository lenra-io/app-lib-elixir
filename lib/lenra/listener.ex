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

    with true <- Module.delete_attribute(env.module, :listener),
         :ok <- Lenra.Utils.AnnotationUtils.check_exists(listeners, id, "listener") do
      Module.put_attribute(
        env.module,
        :listeners,
        Map.put(listeners, id, %{
          mod: env.module,
          fun: fun_name
        })
      )
    end
  end

  def get_id(mod_name, fun_name) do
    "#{mod_name}.#{fun_name}"
  end
end

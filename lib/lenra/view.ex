defmodule Lenra.View do
  use Lenra.Utils.AnnotationUtils, binding_fun: :__views__

  defmacro __using__(_opts) do
    quote do
      @before_compile Lenra.View
      @on_definition Lenra.View
      @views %{}
      import Lenra.ViewsHelper

      def call(fun, args) do
        apply(__MODULE__, fun, [args])
      end

      defoverridable call: 2
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __views__() do
        @views
      end
    end
  end

  def __on_definition__(env, _kind, fun_name, _args, _guards, _body) do
    id = get_id(env.module)
    views = Module.get_attribute(env.module, :views)

    with true <- Module.delete_attribute(env.module, :view),
         :ok <- Lenra.Utils.AnnotationUtils.check_exists(views, id, "view") do
      Module.put_attribute(
        env.module,
        :views,
        Map.put(views, id, %{
          mod: env.module,
          fun: fun_name
        })
      )
    end
  end

  def get_id(mod_name) do
    "#{mod_name}"
  end
end

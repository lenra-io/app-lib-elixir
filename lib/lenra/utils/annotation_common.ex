defmodule Lenra.Utils.AnnotationUtils do
  def check_exists(elements, id, type) do
    case Map.has_key?(elements, id) do
      false ->
        :ok

      true ->
        {:error, "The #{type} #{id} is already defined."}
    end
  end

  defmacro __using__(opts) do
    binding_fun = Keyword.get(opts, :binding_fun)

    quote do
      require Logger

      def load(otp_app) do
        res =
          :application.get_key(otp_app, :modules)
          |> elem(1)
          |> Enum.filter(fn module ->
            not is_nil(module.module_info(:functions)[unquote(binding_fun)])
          end)
          |> Enum.reduce(%{}, fn mod, merged_bindings ->
            module_bindings = apply(mod, unquote(binding_fun), [])

            Map.merge(merged_bindings, module_bindings)
          end)

        Logger.debug("loaded : #{inspect(res)}")
        :persistent_term.put(__MODULE__, res)
      end

      def get_all() do
        :persistent_term.get(__MODULE__)
      end

      def get(id) do
        get_all() |> Map.get(id)
      end

      def call(conn, id, args) do
        case get(id) do
          nil ->
            Logger.error("Unknown element #{id}")
            Lenra.Utils.send_resp(conn, {:error, "Unknown element #{id}"})

          elem ->
            elem.mod.call(elem.fun, args)
            |> Lenra.Utils.send_resp_pipe(conn)
        end
      end
    end
  end
end

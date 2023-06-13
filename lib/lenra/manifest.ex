defmodule Lenra.Manifest do
  defmacro __using__(_opts) do
    quote do
      require Logger

      @behaviour Lenra.Manifest
      @spec call(Plug.Conn.t()) :: Plug.Conn.t()
      def call(conn) do
        res = %{
          "manifest" => %{
            "lenraRoutes" => lenra_routes(),
            "jsonRoutes" => json_routes(),
            "rootView" => root_view()
          }
        }

        Lenra.Utils.send_resp(conn, res)
      end

      def lenra_routes do
        []
      end

      def json_routes do
        []
      end

      def root_view do
        ""
      end

      defoverridable json_routes: 0, lenra_routes: 0, root_view: 0
    end
  end

  @callback lenra_routes() :: list(map())
  @callback json_routes() :: list(map())
end

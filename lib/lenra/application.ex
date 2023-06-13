defmodule Lenra.Application do
  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    manifest_mod = Keyword.fetch!(opts, :manifest_mod)
    # resources_mod = Keyword.fetch!(opts, :resources_mod)
    # listeners_mod = Keyword.fetch!(opts, :listeners_mod)
    # views_mod = Keyword.fetch!(opts, :views_mod)

    quote do
      use Supervisor
      require Logger

      def start_link(init_arg) do
        Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
      end

      @port 3000
      def init(_opts) do
        Logger.debug("Loading Views...")
        Lenra.View.load(unquote(otp_app))
        Logger.debug("Loading Listeners...")
        Lenra.Listener.load(unquote(otp_app))

        children = [
          {
            Plug.Cowboy,
            scheme: :http,
            plug: {
              Lenra.Endpoint,
              otp_app: unquote(otp_app), manifest_mod: unquote(manifest_mod)
              # resources_mod: unquote(resources_mod),
              # listeners_mod: unquote(listeners_mod),
              # views_mod: unquote(views_mod)
            },
            port: @port
          },
          {
            Finch,
            name: HttpClient,
            pools: %{
              :default => [size: 10]
            }
          }
        ]

        res = Supervisor.init(children, strategy: :one_for_one)
        Logger.info("Application is started")
        res
      end
    end
  end
end

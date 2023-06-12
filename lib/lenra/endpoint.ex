defmodule Lenra.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  require Logger

  use Plug.Router, copy_opts_to_assign: :opts

  # This module is a Plug, that also implements it's own plug pipeline, below:

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  post _ do
    otp_app = Keyword.fetch!(conn.assigns.opts, :otp_app)
    manifest_mod = Keyword.fetch!(conn.assigns.opts, :manifest_mod)
    # resources_mod = Keyword.fetch!(conn.assigns.opts, :resources_mod)
    # listeners_mod = Keyword.fetch!(conn.assigns.opts, :listeners_mod)
    # views_mod = Keyword.fetch!(conn.assigns.opts, :views_mod)

    case conn.body_params do
      %{
        "action" => action,
        "props" => props,
        "event" => event,
        "api" => api
      } ->
        Logger.info("Call listener #{action}")
        Lenra.Listener.call(conn, action, %{props: props, event: event, api: api})

      %{"view" => name, "props" => props, "data" => data} ->
        Logger.info("Call view #{name}")
        Lenra.View.call(conn, name, %{props: props, data: data})

      %{"resource" => resource} ->
        Logger.info("Call resource #{resource}")
        Lenra.Resources.call(conn, otp_app, resource)

      _ ->
        Logger.info("Calling manifest")
        manifest_mod.call(conn)
    end
  end

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end
end

defmodule Lenra.Utils do
  require Logger

  def fn_to_string(mod, fun) do
    arity = mod.__info__(:functions) |> Keyword.get(fun)
    "#{inspect(mod)}.#{fun}/#{arity}"
  end

  def get_binding(bindings, key, error_404) do
    if Map.has_key?(bindings, key) do
      {:ok, Map.get(bindings, key)}
    else
      {:error, 404, error_404}
    end
  end

  def to_struct(data, nil), do: data

  def to_struct(data, data_struct) do
    data
    |> Lenra.Api.Data.with_atom()
    |> Lenra.Api.Data.to_struct(data_struct)
  end

  def add_all(map, opts, keys) do
    keys
    |> Enum.reduce(%{}, fn k, new_map ->
      case Keyword.get(opts, k) do
        nil -> new_map
        v -> Map.put(new_map, k, v)
      end
    end)
    |> Map.merge(map)
  end

  def send_resp_pipe(res, conn), do: send_resp(conn, res)
  def send_resp(conn, :error), do: send_resp(conn, {:error, 500, "Unknown error"})
  def send_resp(conn, {:error, reason}), do: send_resp(conn, {:error, 500, reason})

  def send_resp(conn, {:error, status, reason}) when is_bitstring(reason) do
    Logger.debug("Return Error #{status} : #{inspect(reason)}")
    Plug.Conn.send_resp(conn, status, reason)
  end

  def send_resp(conn, {:error, status, reason}) when is_map(reason) or is_list(reason) do
    send_resp(conn, {:error, status, Jason.encode!(reason)})
  end

  def send_resp(conn, :ok), do: send_resp(conn, {:ok, "ok"})

  def send_resp(conn, {:ok, res}) when is_bitstring(res) do
    Logger.debug("Return OK 200 : #{inspect(res)}")
    Plug.Conn.send_resp(conn, 200, res)
  end

  def send_resp(conn, {:ok, res}) when is_list(res) or is_map(res) or is_struct(res) do
    send_resp(conn, {:ok, Jason.encode!(res)})
  end

  def send_resp(conn, res), do: send_resp(conn, {:ok, Jason.encode!(res)})
end

defmodule Lenra.Api.Data do
  @type data_api_opts :: [
          as: nil | struct()
        ]

  def get_doc(api, coll, id, opts \\ []) do
    url = Map.get(api, "url")

    Finch.build(
      :get,
      "#{url}/app/colls/#{coll}/docs/#{id}",
      headers(api)
    )
    |> send_request(opts)
  end

  def create_doc(api, coll, doc, opts \\ []) do
    url = Map.get(api, "url")
    clean_doc = doc |> to_map() |> remove_id()

    Finch.build(
      :post,
      "#{url}/app/colls/#{coll}/docs",
      headers(api),
      clean_doc |> Jason.encode!()
    )
    |> send_request(opts)
  end

  defp remove_id(doc) when is_map(doc) do
    doc |> Map.delete("_id")
  end

  def update_doc(api, coll, doc, opts \\ []) do
    clean_doc = doc |> to_map()

    url = Map.get(api, "url")
    id = Map.get(clean_doc, "_id")

    Finch.build(
      :put,
      "#{url}/app/colls/#{coll}/docs/#{id}",
      headers(api),
      Jason.encode!(clean_doc)
    )
    |> send_request(opts)
  end

  def delete_doc(api, coll, doc_id, opts \\ []) do
    Finch.build(
      :delete,
      "#{api.url}/app/colls/#{coll}/docs/#{doc_id}",
      headers(api)
    )
    |> send_request(opts)
  end

  def execute_query(api, coll, query, opts \\ []) do
    url = Map.get(api, "url")

    Finch.build(
      :post,
      "#{url}/app/colls/#{coll}/docs/find",
      headers(api),
      Jason.encode!(query)
    )
    |> send_request(opts)
  end

  defp send_request(request, opts) do
    Finch.request(request, HttpClient)
    |> case do
      {:ok, response} ->
        body = decode!(response.body, opts)
        {:ok, body}
      {:error, %Mint.TransportError{reason: :econnrefused}} ->
        {:error, "Lenra API not reachable. Reason #{:econnrefused}"}

      err ->
        err
    end
  end

  defp decode!(body, opts) do
    struct = Keyword.get(opts, :as)

    if not is_nil(struct) do
      body
      |> Jason.decode!()
      |> with_atom()
      |> to_struct(struct)
    else
      Jason.decode!(body)
    end
  rescue
    _e ->
      struct = Keyword.get(opts, :as)
      raise "Could not parse #{body} into #{inspect(struct)}"
  end

  def with_atom(list) when is_list(list) do
    Enum.map(list, &with_atom/1)
  end

  def with_atom(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  def to_struct(map, struct) when is_map(map) do
    Kernel.struct!(struct, map)
  end

  def to_struct(list, struct) when is_list(list) do
    Enum.map(list, &to_struct(&1, struct))
  end

  def to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> to_map()
  end

  def to_map(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {key_to_str(k), to_map(v)} end)
  end

  def to_map(e), do: e

  defp key_to_str(k) when is_atom(k), do: Atom.to_string(k)
  defp key_to_str(k), do: k

  defp headers(api) do
    token = Map.get(api, "token")

    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]
  end
end

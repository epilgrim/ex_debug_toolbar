alias ExDebugToolbar.Data.Collection

defimpl Collection, for: Plug.Conn do
  @response_keys ~w(status resp_charset assigns resp_cookies resp_headers private)a
  def add(_, {:request, %Plug.Conn{} = new_conn}), do: new_conn |> remove_body
  def add(conn, {:response, %Plug.Conn{} = new_conn}) do
    new_conn |> Map.take(@response_keys) |> (&Map.merge(conn, &1)).()
  end

  defp remove_body(conn), do: %{conn | resp_body: nil}
end

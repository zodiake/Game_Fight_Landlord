defmodule RawWeb.PageControllerTest do
  use RawWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
  end
end

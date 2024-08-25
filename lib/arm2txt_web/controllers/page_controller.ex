defmodule Arm2txtWeb.PageController do
  require Logger
  use Arm2txtWeb, :controller

  def submit(conn, params) when params == %{} do
    conn
    |> put_status(:unprocessable_entity)
    |> assign(:result, "չկան պարամետրներ։ ֆայլ ընտրե՞լ ես։")
    |> render(:no_result)
  end

  def submit(conn, %{"file" => nil}) do
    conn
    |> put_status(:unprocessable_entity)
    |> assign(:result, "ֆայլ չի նշուել։")
    |> render(:no_result)
  end

  def submit(conn, %{"file" => ""}) do
    conn
    |> put_status(:unprocessable_entity)
    |> assign(:result, "ֆայլը դատարկ է։")
    |> render(:no_result)
  end

  def submit(conn, %{"file" => file}) when file != "" do
    {microseconds, result} =
      :timer.tc(Arm2txt.OCR, :get_text,
        [
          file.filename,
          file.path,
          file.content_type
        ]
      )
    duration = microseconds / 1000
    render(conn, :result, result: result, duration: duration)
  end

  # TODO Use SSE for long running jobs
  # This can also act as a reference in the future.
  def poll(conn, %{"id" => id}) when id != "" do
    conn = conn
    |> put_resp_header("Cache-Control", "no-cache")
    |> put_resp_header("Connection", "keep-alive")
    |> put_resp_header("Content-Type", "text/event-stream")
    |> send_chunked(200)

    Phoenix.PubSub.subscribe(Arm2txt.PubSub, id)
    chunk(conn, "event: result\ndata: hello there!\n\n")
    sse_loop(conn, self())
  end

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  defp sse_loop(conn, pid) do
    receive do
      {:ok, msg} ->
        chunk(conn, "event: result\ndata: #{msg}\n\n")
        sse_loop(conn, pid)
      {:close} ->
        chunk(conn, "event: bye\ndata: bye\n\n")
        halt(conn)
      {:DOWN, _reference, :process, ^pid, _type} ->
        nil
      other ->
        IO.inspect(other)
        sse_loop(conn, pid)
    end
  end
end

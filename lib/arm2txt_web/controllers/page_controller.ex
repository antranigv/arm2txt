defmodule Arm2txtWeb.PageController do
  require Logger
  use Arm2txtWeb, :controller

  def submit(conn, params) when params == %{} do
    render(conn, :result, layout: false, result: "No parameters", duration: "0")
  end

  def submit(conn, %{"file" => nil}) do
    render(conn, :result, layout: false, result: "File is missing", duration: "0")
  end

  def submit(conn, %{"file" => ""}) do
    render(conn, :result, layout: false, result: "File is empty", duration: "0")
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
    render(conn, :result, layout: false, result: result, duration: duration)
  end

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, result: "")
  end
end

defmodule Arm2txt.OCR do
  def get_text(name, path, "application/pdf") do
    {res, ret} = System.cmd("convert", [ path <> "[0-19]", path <> "-%02d.png" ])
    filedirpath  = Path.dirname(path)
    filebasename = Path.basename(path)
    pngs =
      filedirpath
      |> File.ls!
      |> Enum.filter(fn x -> String.starts_with?(x, filebasename <> "-") end)
      |> Enum.sort

    Enum.map(pngs,
      fn png -> get_text("", filedirpath <> "/" <> png, "image/png") end
    )
    |> Enum.join("\n\n")
  end

  def get_text(name, path, content_type) do
    {res, ret} = System.cmd("tesseract", ["-l", "best/Armenian", path, "-"])
    File.rm!(path)
    res
  end
end

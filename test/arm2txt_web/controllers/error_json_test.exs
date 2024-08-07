defmodule Arm2txtWeb.ErrorJSONTest do
  use Arm2txtWeb.ConnCase, async: true

  test "renders 404" do
    assert Arm2txtWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Arm2txtWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

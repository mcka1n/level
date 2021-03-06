defmodule LevelWeb.Util.SvgToElmController do
  @moduledoc false

  use LevelWeb, :controller

  import Level.Gettext

  plug :put_layout, "page.html"

  def index(conn, _params) do
    conn
    |> set_assigns()
    |> render("index.html")
  end

  def create(conn, %{"converter" => %{"svg" => raw_svg}}) do
    raw_svg
    |> Level.Svg.to_elm()
    |> respond_with_elm(conn)
  end

  defp set_assigns(conn) do
    conn
    |> assign(:module, "svg_to_elm")
    |> assign(:og, og_data())
    |> assign(:page_title, "Convert SVG to Elm")
  end

  defp respond_with_elm({:ok, value}, conn) do
    conn
    |> set_assigns()
    |> assign(:elm_output, value)
    |> render("index.html")
  end

  defp respond_with_elm({:error, _}, conn) do
    conn
    |> set_assigns()
    |> put_flash(:error, generic_error())
    |> render("index.html")
  end

  defp generic_error do
    dgettext(
      "errors",
      "Hmm...something went wrong. If the problem persists, please file a bug report on GitHub."
    )
  end

  defp og_data do
    %{
      title: "Convert SVG to Elm",
      description:
        "A free little utility for converting raw SVGs into elm/svg code, from the maker of Level.",
      image: "/images/avatar-light.png",
      url: "https://level.app/svg-to-elm"
    }
  end
end

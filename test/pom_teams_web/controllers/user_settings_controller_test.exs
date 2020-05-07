defmodule PomTeamsWeb.UserSettingsControllerTest do
  use PomTeamsWeb.ConnCase

  alias PomTeams.UserContext
  alias PomTeams.UserContext.User

  @create_attrs %{long_break_minutes: 42, pomodoro_minutes: 42, short_break_minutes: 42, short_breaks_limit: 42}
  @update_attrs %{long_break_minutes: 43, pomodoro_minutes: 43, short_break_minutes: 43, short_breaks_limit: 43}
  @invalid_attrs %{long_break_minutes: nil, pomodoro_minutes: nil, short_break_minutes: nil, short_breaks_limit: nil}

  def fixture(:setting) do
    {:ok, setting} = User.create_setting(@create_attrs)
    setting
  end

  describe "index" do
    test "lists all settings", %{conn: conn} do
      conn = get(conn, Routes.setting_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Settings"
    end
  end

  describe "new setting" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.setting_path(conn, :new))
      assert html_response(conn, 200) =~ "New Setting"
    end
  end

  describe "create setting" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.setting_path(conn, :create), setting: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.setting_path(conn, :show, id)

      conn = get(conn, Routes.setting_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Setting"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.setting_path(conn, :create), setting: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Setting"
    end
  end

  describe "edit setting" do
    setup [:create_setting]

    test "renders form for editing chosen setting", %{conn: conn, setting: setting} do
      conn = get(conn, Routes.setting_path(conn, :edit, setting))
      assert html_response(conn, 200) =~ "Edit Setting"
    end
  end

  describe "update setting" do
    setup [:create_setting]

    test "redirects when data is valid", %{conn: conn, setting: setting} do
      conn = put(conn, Routes.setting_path(conn, :update, setting), setting: @update_attrs)
      assert redirected_to(conn) == Routes.setting_path(conn, :show, setting)

      conn = get(conn, Routes.setting_path(conn, :show, setting))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, setting: setting} do
      conn = put(conn, Routes.setting_path(conn, :update, setting), setting: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Setting"
    end
  end

  describe "delete setting" do
    setup [:create_setting]

    test "deletes chosen setting", %{conn: conn, setting: setting} do
      conn = delete(conn, Routes.setting_path(conn, :delete, setting))
      assert redirected_to(conn) == Routes.setting_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.setting_path(conn, :show, setting))
      end
    end
  end

  defp create_setting(_) do
    setting = fixture(:setting)
    %{setting: setting}
  end
end

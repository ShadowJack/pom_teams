defmodule PomTeamsWeb.UserSettingsController do
  use PomTeamsWeb, :controller

  alias PomTeams.UserContext.User
  alias PomTeams.UserContext

  require Logger

  def show(conn, params) do
    Logger.info(params)

    # setting = UserContext.get_or_create!()
    user = %User{}
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    conn
    # setting = User.get_setting!(id)
    # changeset = User.change_setting(setting)
    # render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  def update(conn, %{"id" => id, "setting" => setting_params}) do
    conn
    # setting = User.get_setting!(id)
    # 
    # case User.update_setting(setting, setting_params) do
    #   {:ok, setting} ->
    #     conn
    #     |> put_flash(:info, "Setting updated successfully.")
    #     |> redirect(to: Routes.setting_path(conn, :show, setting))
    # 
    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", setting: setting, changeset: changeset)
    # end
  end
end

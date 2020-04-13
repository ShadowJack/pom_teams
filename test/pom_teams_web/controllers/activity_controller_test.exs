defmodule PomTeams.ActivityControllerTest do
  use PomTeamsWeb.ConnCase, async: false

  alias PomTeams.PomTimerContext.{PomTimer, PomTimerSupervisor}

  describe "start action" do
    test "is processed successfully", %{conn: conn} do
      params = build_params("pomstart")
      conn = post(conn, "api/activity", params)

      assert conn.status == 200

      timer = PomTimerSupervisor.get_pom_timer(params["from"]["id"])
      assert timer != nil
      assert {:ok, :running} == PomTimer.get_state(timer)
    end
  end

  describe "pause action" do
    test "returns error when no timer is running", %{conn: conn} do
      params = build_params("pompause")
      conn = post(conn, "api/activity", params)

      assert response(conn, 400) =~ "No pomodoro timer is running"
    end

    test "is processed successfully", %{conn: conn} do
      params = build_params("pomstart")
      user_external_id = params["from"]["id"]
      conn = post(conn, "api/activity", params)

      params = build_params("pompause", user_external_id)
      conn = post(conn, "api/activity", params)

      assert conn.status == 200

      timer = PomTimerSupervisor.get_pom_timer(user_external_id)
      assert timer != nil
      assert {:ok, :stopped} == PomTimer.get_state(timer)
    end
  end

  describe "reset action" do
    test "returns error when no timer is running", %{conn: conn} do
      params = build_params("pomreset")
      conn = post(conn, "api/activity", params)

      assert response(conn, 400) =~ "No pomodoro timer is running"
    end

    test "is processed successfully", %{conn: conn} do
      params = build_params("pomstart")
      user_external_id = params["from"]["id"]
      conn = post(conn, "api/activity", params)

      params = build_params("pomreset", user_external_id)
      conn = post(conn, "api/activity", params)

      assert conn.status == 200

      timer = PomTimerSupervisor.get_pom_timer(user_external_id)
      assert timer != nil
      assert {:ok, :running} == PomTimer.get_state(timer)
    end
  end

  describe "stop action" do
    test "returns error when no timer is running", %{conn: conn} do
      params = build_params("pomreset")
      conn = post(conn, "api/activity", params)

      assert response(conn, 400) =~ "No pomodoro timer is running"
    end

    test "is processed successfully", %{conn: conn} do
      params = build_params("pomstart")
      user_external_id = params["from"]["id"]
      conn = post(conn, "api/activity", params)

      params = build_params("pomstop", user_external_id)
      conn = post(conn, "api/activity", params)

      assert conn.status == 200

      timer = PomTimerSupervisor.get_pom_timer(user_external_id)
      assert timer != nil
      assert {:ok, :stopped} == PomTimer.get_state(timer)
    end
  end

  defp build_params(text, user_external_id \\ "test_#{Ecto.UUID.generate()}") do
    %{
      "channelData" => %{"tenant" => %{"id" => "088cc143-85a1-4c43-9030-fa899b92b0e9"}},
      "channelId" => "msteams",
      "conversation" => %{
        "conversationType" => "personal",
        "id" =>
          "a:1lqfF2B_Xu7a7veoKZyfteOjhwjbdBu7KmJNxVAr-_nia3vFG3cwFiX3GR_QzF1Y4aHEOBzSl9D6SBas5v0T2Dli2bhT4MuLQtdMgHupdSaG4cZHrKRAwu0VFls85TDsC",
        "tenantId" => "088cc143-85a1-4c43-9030-fa899b92b0e9"
      },
      "entities" => [
        %{"country" => "IE", "locale" => "en-IE", "platform" => "Mac", "type" => "clientInfo"}
      ],
      "from" => %{
        "aadObjectId" => "28c7de74-f24d-47df-a6b2-d12c8f121703",
        "id" => user_external_id,
        "name" => "Konstantin Pavlovsky"
      },
      "id" => "1586724433762",
      "localTimestamp" => "2020-04-12T23:47:13.7778039+03:00",
      "locale" => "en-IE",
      "recipient" => %{"id" => "28:69d8e50f-3e0d-4725-9966-1d91d2a2fa55", "name" => "PomBot"},
      "serviceUrl" => "https://smba.trafficmanager.net/emea/",
      "text" => text,
      "textFormat" => "plain",
      "timestamp" => "2020-04-12T20:47:13.7778039Z",
      "type" => "message"
    }
  end
end

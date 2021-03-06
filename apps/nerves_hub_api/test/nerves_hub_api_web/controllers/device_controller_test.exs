defmodule NervesHubAPIWeb.DeviceControllerTest do
  use NervesHubAPIWeb.ConnCase, async: false
  alias NervesHubWebCore.{Devices, Fixtures}

  describe "create devices" do
    test "renders device when data is valid", %{conn: conn, org: org} do
      identifier = "api-device-1234"
      device = %{identifier: identifier, description: "test device", tags: ["test"]}

      conn = post(conn, device_path(conn, :create, org.name), device)
      assert json_response(conn, 201)["data"]

      conn = get(conn, device_path(conn, :show, org.name, device.identifier))
      assert json_response(conn, 200)["data"]["identifier"] == identifier
    end

    test "renders errors when data is invalid", %{conn: conn, org: org} do
      conn = post(conn, key_path(conn, :create, org.name))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "index" do
    test "lists all devices for an org", %{conn: conn, org: org} do
      product = Fixtures.product_fixture(org)
      org_key = Fixtures.org_key_fixture(org)
      firmware = Fixtures.firmware_fixture(org_key, product)

      device = Fixtures.device_fixture(org, firmware)

      conn = get(conn, device_path(conn, :index, org.name))

      assert json_response(conn, 200)["data"]

      assert Enum.find(conn.assigns.devices, fn %{identifier: identifier} ->
               device.identifier == identifier
             end)
    end
  end

  describe "delete devices" do
    test "deletes chosen device", %{conn: conn, org: org} do
      product = Fixtures.product_fixture(org)
      org_key = Fixtures.org_key_fixture(org)
      firmware = Fixtures.firmware_fixture(org_key, product)

      Fixtures.device_fixture(org, firmware)

      [to_delete | _] = Devices.get_devices(org)
      conn = delete(conn, device_path(conn, :delete, org.name, to_delete.identifier))
      assert json_response(conn, 204)["data"]

      conn = get(conn, device_path(conn, :show, org.name, to_delete.identifier))
      assert json_response(conn, 404)
    end
  end

  describe "update devices" do
    test "updates chosen device", %{conn: conn, org: org} do
      product = Fixtures.product_fixture(org)
      org_key = Fixtures.org_key_fixture(org)
      firmware = Fixtures.firmware_fixture(org_key, product)

      Fixtures.device_fixture(org, firmware)

      [to_update | _] = Devices.get_devices(org)

      conn =
        put(conn, device_path(conn, :update, org.name, to_update.identifier), %{
          tags: ["a", "b", "c", "d"]
        })

      assert json_response(conn, 201)["data"]

      conn = get(conn, device_path(conn, :show, org.name, to_update.identifier))
      assert json_response(conn, 200)
      assert conn.assigns.device.tags == ["a", "b", "c", "d"]
    end
  end

  describe "authenticate devices" do
    test "valid certificate", %{conn: conn, org: org} do
      product = Fixtures.product_fixture(org)
      org_key = Fixtures.org_key_fixture(org)
      firmware = Fixtures.firmware_fixture(org_key, product)

      device = Fixtures.device_fixture(org, firmware)
      %{cert: ca, key: ca_key} = Fixtures.ca_certificate_fixture(org)

      cert =
        X509.PrivateKey.new_ec(:secp256r1)
        |> X509.PublicKey.derive()
        |> X509.Certificate.new("CN=#{device.identifier}", ca, ca_key)

      _device_certificate = Fixtures.device_certificate_fixture(device, cert)

      cert64 =
        cert
        |> X509.Certificate.to_pem()
        |> Base.encode64()

      conn = post(conn, device_path(conn, :auth, org.name), %{"certificate" => cert64})
      assert json_response(conn, 200)["data"]
    end
  end
end

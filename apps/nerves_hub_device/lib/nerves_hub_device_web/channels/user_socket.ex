defmodule NervesHubDeviceWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", NervesHubWWWWeb.RoomChannel
  channel("firmware:*", NervesHubDeviceWeb.DeviceChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(_params, socket, %{peer_data: %{ssl_cert: ssl_cert}}) do
    certificate = X509.Certificate.from_der!(ssl_cert)

    case NervesHubDevice.SSL.verify_device(certificate) do
      {:ok, db_cert} -> {:ok, assign(socket, :certificate, db_cert)}
      _e -> :error
    end
  end

  def connect(_params, _socket, _connect_info) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     NervesHubWWWWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(%{assigns: %{certificate: certificate}}), do: "device_socket:#{certificate.device_id}"
  def id(_socket), do: nil
end

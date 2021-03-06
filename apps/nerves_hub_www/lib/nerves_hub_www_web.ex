defmodule NervesHubWWWWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use NervesHubWWWWeb, :controller
      use NervesHubWWWWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: NervesHubWWWWeb
      import Plug.Conn
      import NervesHubWWWWeb.Router.Helpers
      import NervesHubWWWWeb.Gettext

      def whitelist(params, keys) do
        keys
        |> Enum.filter(fn x -> !is_nil(params[to_string(x)]) end)
        |> Enum.into(%{}, fn x -> {x, params[to_string(x)]} end)
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/nerves_hub_www_web/templates",
        namespace: NervesHubWWWWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import NervesHubWWWWeb.Router.Helpers
      import NervesHubWWWWeb.ErrorHelpers
      import NervesHubWWWWeb.Gettext
    end
  end

  def api_view do
    quote do
      use Phoenix.View,
        root: "lib/nerves_hub_www_web/templates",
        namespace: NervesHubWWWWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]

      import NervesHubWWWWeb.Router.Helpers
      import NervesHubWWWWeb.ErrorHelpers
      import NervesHubWWWWeb.Gettext

      def render("error.json", %{error: error}) do
        %{
          error: error
        }
      end
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import NervesHubWWWWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

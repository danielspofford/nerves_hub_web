defmodule NervesHubWWWWeb.DeploymentView do
  use NervesHubWWWWeb, :view

  alias NervesHubWebCore.Firmwares.Firmware
  alias NervesHubWebCore.Deployments.Deployment

  def firmware_dropdown_options(firmwares) do
    firmwares
    |> Enum.map(&[value: &1.id, key: firmware_display_name(&1)])
  end

  def firmware_summary(%Firmware{version: nil} = f) do
    [
      f.platform,
      f.architecture
    ]
    |> Enum.join(" - ")
  end

  def firmware_summary(%Firmware{} = f) do
    [
      "v:#{firmware_display_name(f)}",
      f.platform,
      f.architecture
    ]
    |> Enum.join(" - ")
  end

  def firmware_display_name(%Firmware{} = f) do
    case f.version do
      nil -> "--"
      version -> "#{version}"
    end
  end

  def version(%Deployment{conditions: %{"version" => ""}}), do: "-"
  def version(%Deployment{conditions: %{"version" => version}}), do: version

  def active(%Deployment{is_active: true}), do: "Yes"
  def active(%Deployment{is_active: false}), do: "No"

  def opposite_status(%Deployment{is_active: true}), do: "Inactive"
  def opposite_status(%Deployment{is_active: false}), do: "Active"

  def tags(%Deployment{conditions: %{"tags" => tags}}), do: tags
end

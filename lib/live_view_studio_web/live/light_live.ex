defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: "3000")
    IO.inspect(socket)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background-color: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="/images/light-off.svg" alt="light off" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" alt="light down" />
      </button>
      <button phx-click="random">
        <img src="/images/fire.svg" alt="fire" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" alt="light up" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" alt="light on" />
      </button>
    </div>
    <form class="pt-12" phx-change="range_change">
      <input
        type="range"
        min="0"
        max="100"
        name="brightness"
        value={@brightness}
      />
    </form>
    <h2 class="pt-12 text-lg text-start">Color Temperature</h2>
    <form class="pt-2" phx-change="temp_change">
      <div class="temps space-y-2">
        <%= for temp <- ["3000", "4000", "5000"] do %>
          <div class="flex items-center space-x-2">
            <input
              type="radio"
              id={temp}
              name="temp"
              value={temp}
              checked={@temp == temp}
            />
            <div
              class="w-4 h-4 rounded"
              style={"background-color: #{temp_color(temp)}"}
            />
            <label for={temp}><%= temp %></label>
          </div>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("on", _payload, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("up", _payload, socket) do
    socket = update(socket, :brightness, &min(100, &1 + 10))
    {:noreply, socket}
  end

  def handle_event("down", _payload, socket) do
    socket = update(socket, :brightness, &max(0, &1 - 10))
    {:noreply, socket}
  end

  def handle_event("random", _payload, socket) do
    socket = assign(socket, brightness: Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("range_change", payload, socket) do
    %{"brightness" => brightness} = payload
    socket = assign(socket, brightness: String.to_integer(brightness))
    {:noreply, socket}
  end

  def handle_event("temp_change", payload, socket) do
    %{"temp" => temp} = payload
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end

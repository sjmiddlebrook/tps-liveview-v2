defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        form: to_form(changeset),
        coffees: 0
      )

    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect(self(), label: "RENDER")

    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={
              if @live_action != :new && server == @selected_server,
                do: "selected"
            }
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.form for={@form} phx-submit="save" phx-change="validate">
              <div class="field">
                <.input
                  field={@form[:name]}
                  placeholder="Name"
                  autocomplete="off"
                  phx-debounce="1500"
                />
              </div>
              <div class="field">
                <.input
                  field={@form[:framework]}
                  placeholder="Framework"
                  phx-debounce="1500"
                  autocomplete="off"
                />
              </div>
              <div class="field">
                <.input
                  field={@form[:size]}
                  placeholder="Size (MB)"
                  phx-debounce="1500"
                  type="number"
                />
              </div>
              <.button phx-disable-with="Saving...">Save</.button>
              <.link patch={~p"/servers"} class="cancel">
                Cancel
              </.link>
            </.form>
          <% else %>
            <.server server={@selected_server} />
          <% end %>
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust Lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def server(assigns) do
    IO.inspect(self(), label: "SERVER")

    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <span class={@server.status}>
          <%= @server.status %>
        </span>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    IO.inspect(self(), label: "HANDLE PARAMS ID = #{id}")
    server = Servers.get_server!(id)

    {:noreply,
     assign(socket,
       selected_server: server,
       page_title: "#{server.name} · Servers"
     )}
  end

  def handle_params(_params, _uri, socket) do
    IO.inspect(self(), label: "HANDLE PARAMS CATCH ALL")
    socket = fill_server_fallback(socket, socket.assigns.live_action)

    {:noreply, socket}
  end

  def fill_server_fallback(socket, :new) do
    assign(socket,
      selected_server: nil,
      page_title: "Add New Server"
    )
  end

  def fill_server_fallback(socket, _) do
    server = hd(socket.assigns.servers)

    assign(socket,
      selected_server: server,
      page_title: "#{server.name} · Servers"
    )
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket = update(socket, :servers, &[server | &1])
        changeset = Servers.change_server(%Server{})
        socket = assign(socket, form: to_form(changeset))
        socket = put_flash(socket, :info, "Server created!")
        socket = push_patch(socket, to: ~p"/servers/#{server.id}")
        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, form: to_form(changeset))
        socket = put_flash(socket, :error, "Error creating server.")
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    socket = assign(socket, form: to_form(changeset))
    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    IO.inspect(self(), label: "HANDLE EVENT")
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end
end

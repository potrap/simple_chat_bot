defmodule ChatBotWeb.ChatLive do
  use ChatBotWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:stage, :start)
     |> assign(:history, [])
     |> assign(:current_options, initial_options())
    }
  end

  defp get_option(options, key) do
    Enum.find(options, &(&1.key == key)) || %{key: key, text: "Невідомий варіант", next_options: []}
  end

  def handle_event("select_option", %{"option" => option_key}, socket) do
    case socket.assigns.stage do
      :completed ->
        # Обработка рестарта
        {:noreply,
         socket
         |> assign(:history, [])
         |> assign(:stage, :start)
         |> assign(:current_options, initial_options())
        }

      _ ->
        option = get_option(socket.assigns.current_options, option_key)
        new_history = [%{text: option.text, is_bot: false} | socket.assigns.history]

        case socket.assigns.stage do
          :start ->
            handle_stage_transition(socket, new_history, :middle, option.next_options)

          :middle ->
            handle_stage_transition(socket, new_history, :final, option.next_options)

          :final ->
            bot_response = "Ви обрали шлях: #{option.text}. Дякуємо за спілкування!"
            {:noreply,
             socket
             |> assign(:history, [%{text: bot_response, is_bot: true} | new_history])
             |> assign(:stage, :completed)
             |> assign(:current_options, [%{key: "restart", text: "🔄 Почати знову"}])
            }
        end
    end
  end

  def handle_event("restart", _, socket) do
    {:noreply,
     socket
     |> assign(:history, [])
     |> assign(:stage, :start)
     |> assign(:current_options, initial_options())
    }
  end

  defp handle_stage_transition(socket, history, next_stage, next_options) do
    bot_response = get_bot_response(socket.assigns.stage, next_stage)
    updated_history = [%{text: bot_response, is_bot: true} | history]

    {:noreply,
     socket
     |> assign(:history, updated_history)
     |> assign(:stage, next_stage)
     |> assign(:current_options, next_options)
    }
  end

  defp get_bot_response(:start, :middle), do: "Цікавий вибір! Що ви оберете далі?"
  defp get_bot_response(:middle, :final), do: "Чудово! І останнє питання:"
  defp get_bot_response(_, _), do: "Продовжимо:"

  defp initial_options() do
    [
      %{key: "food", text: "🍕 Їжа", next_options: food_options()},
      %{key: "sports", text: "⚽ Спорт", next_options: sports_options()},
      %{key: "music", text: "🎵 Музика", next_options: music_options()}
    ]
  end

  defp food_options() do
    [
      %{key: "italian", text: "🍝 Італійська", next_options: italian_options()},
      %{key: "japanese", text: "🍣 Японська", next_options: japanese_options()},
      %{key: "ukrainian", text: "🥣 Українська", next_options: ukrainian_options()}
    ]
  end

  defp sports_options() do
    [
      %{key: "football", text: "⚽ Футбол", next_options: football_options()},
      %{key: "basketball", text: "🏀 Баскетбол", next_options: basketball_options()},
      %{key: "boxing", text: "🥊 Бокс", next_options: boxing_options()}
    ]
  end

  defp music_options() do
    [
      %{key: "pop", text: "🎤 Поп", next_options: pop_options()},
      %{key: "rock", text: "🎸 Рок", next_options: rock_options()},
      %{key: "electronic", text: "🎧 Електронна", next_options: electronic_options()}
    ]
  end

  # Italian food options
  defp italian_options() do
    [
      %{key: "pizza", text: "🍕 Піца", next_options: []},
      %{key: "pasta", text: "🍝 Паста", next_options: []},
      %{key: "risotto", text: "🍚 Різотто", next_options: []}
    ]
  end

  # Japanese food options
  defp japanese_options() do
    [
      %{key: "sushi", text: "🍣 Суші", next_options: []},
      %{key: "ramen", text: "🍜 Рамен", next_options: []},
      %{key: "tempura", text: "🍤 Темпура", next_options: []}
    ]
  end

  # Ukrainian food options
  defp ukrainian_options() do
    [
      %{key: "borsch", text: "🍲 Борщ", next_options: []},
      %{key: "varenyky", text: "🥟 Вареники", next_options: []},
      %{key: "salo", text: "🥓 Сало", next_options: []}
    ]
  end

  # Football options
  defp football_options() do
    [
      %{key: "premier_league", text: "🏴󠁧󠁢󠁥󠁮󠁧󠁿 Прем'єр-ліга", next_options: []},
      %{key: "la_liga", text: "🇪🇸 Ла Ліга", next_options: []},
      %{key: "ukrainian_league", text: "🇺🇦 УПЛ", next_options: []}
    ]
  end

  # Basketball options
  defp basketball_options() do
    [
      %{key: "nba", text: "🇺🇸 НБА", next_options: []},
      %{key: "euroleague", text: "🏀 Євроліга", next_options: []},
      %{key: "fiba", text: "🏆 ФІБА", next_options: []}
    ]
  end

  # Boxing options
  defp boxing_options() do
    [
      %{key: "heavyweight", text: "🥊 Важка вага", next_options: []},
      %{key: "middleweight", text: "🥊 Середня вага", next_options: []},
      %{key: "ukrainian_boxers", text: "🇺🇦 Українські боксери", next_options: []}
    ]
  end

  # Pop music options
  defp pop_options() do
    [
      %{key: "top40", text: "📊 Топ-40", next_options: []},
      %{key: "kpop", text: "🇰🇷 K-pop", next_options: []},
      %{key: "ukrainian_pop", text: "🇺🇦 Український поп", next_options: []}
    ]
  end

  # Rock music options
  defp rock_options() do
    [
      %{key: "classic_rock", text: "🎸 Класичний рок", next_options: []},
      %{key: "alternative", text: "🎤 Альтернатива", next_options: []},
      %{key: "ukrainian_rock", text: "🇺🇦 Український рок", next_options: []}
    ]
  end

  # Electronic music options
  defp electronic_options() do
    [
      %{key: "house", text: "🕺 Хаус", next_options: []},
      %{key: "techno", text: "⚡ Техно", next_options: []},
      %{key: "edm", text: "🎧 EDM", next_options: []}
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="chat-container">
      <h1>Чат-бот з варіантами</h1>

      <div class="chat-history">
        <%= for message <- Enum.reverse(@history) do %>
          <div class={"message #{if message.is_bot, do: "bot", else: "user"}"}>
            <%= message.text %>
          </div>
        <% end %>

        <%= if @stage == :completed do %>
          <div class="message bot">
            Розмова завершена. Хочете почати знову?
          </div>
        <% end %>
      </div>

      <div class="options">
      <%= if @stage == :completed do %>
        <button phx-click="restart" class="restart-button">
          🔄 Почати нову розмову
        </button>
      <% else %>
        <%= for option <- @current_options do %>
          <button phx-click="select_option" phx-value-option={option.key}>
            <%= option.text %>
          </button>
        <% end %>
      <% end %>
    </div>
  </div>
    """
  end
end

module InteractionsHelper
  def interaction_channel_label(interaction)
    I18n.t("enums.interaction.channel.#{interaction.channel}", default: interaction.channel)
  end

  def interaction_status_label(interaction)
    interaction.completed? ? "完了済" : "対応中"
  end

  def interaction_status_badge_class(interaction)
    base = "inline-flex items-center justify-center rounded text-xs border"
    color = interaction.completed? ? "bg-gray-100 text-gray-600 border-gray-200" : "bg-blue-100 text-blue-600 border-blue-200"

    "#{base} #{color}"
  end

  def interaction_status_text_class(interaction)
    interaction.completed? ? "text-gray-600" : "text-blue-600"
  end
end

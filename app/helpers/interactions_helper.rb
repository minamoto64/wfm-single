module InteractionsHelper
  def interaction_channel_label(interaction)
    I18n.t("enums.interaction.channel.#{interaction.channel}", default: interaction.channel)
  end

  def interaction_status_label(interaction)
    interaction.completed? ? "完了済" : "対応中"
  end

  def interaction_status_badge_class(interaction)
    base = "inline-flex items-center justify-center rounded text-xs border"
    color = interaction.completed? ? "bg-green-100 text-green-600 border-green-200" : "bg-blue-100 text-blue-600 border-blue-200"

    "#{base} #{color}"
  end
end

module InteractionsHelper
  def interaction_channel_label(interaction)
    I18n.t("enums.interaction.channel.#{interaction.channel}", default: interaction.channel)
  end
end

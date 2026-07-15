module NoticesHelper
  def notice_level_label(notice)
    I18n.t("enums.notice.level.#{notice.level}", default: notice.level)
  end

  def notice_level_badge_class(notice)
    base = "inline-flex items-center justify-center rounded text-xs border"
    color = notice.important? ? "bg-amber-100 text-amber-700 border-amber-200" : "bg-gray-100 text-gray-600 border-gray-200"

    "#{base} #{color}"
  end
end

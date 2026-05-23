module NoticesHelper
  def notice_level_label(notice)
    I18n.t("enums.notice.level.#{notice.level}", default: notice.level)
  end
end

module UsersHelper
  def user_admin_label(user)
    I18n.t("users.admin.#{user.admin?}")
  end

  def user_admin_badge_class(user)
    base = "inline-flex items-center justify-center rounded text-xs border"
    color = user.admin? ? "bg-amber-100 text-amber-700 border-amber-200" : "bg-gray-100 text-gray-600 border-gray-200"

    "#{base} #{color}"
  end
end

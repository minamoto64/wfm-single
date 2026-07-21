module ApplicationHelper
  include Pagy::Frontend

  def navigation_tabs
    [
      { path: interactions_path, label: "応対履歴", name: "interactions" },
      { path: tasks_path,        label: "タスク",   name: "tasks" },
      { path: notices_path,      label: "お知らせ", name: "notices" },
      { path: customers_path,    label: "顧客",     name: "customers" },
      { path: users_path,        label: "従業員",   name: "users" }
    ]
  end

  def tab_link_to(tab)
    active  = controller_name == tab[:name]
    classes = %w[flex-1 text-center py-3 border-b-2 text-sm sm:text-base]
    classes += active ? %w[border-blue-500 text-blue-600 font-bold]
                      : %w[border-transparent text-gray-600 hover:text-gray-900 font-normal]

    link_to tab[:path],
            class: classes,
            data:  { tab_name: tab[:name] } do
      tab[:label]
    end
  end

  def pagy_tailwind_nav(pagy)
    return "".html_safe if pagy.pages <= 1

    link_classes    = "min-w-8 h-8 px-2 inline-flex items-center justify-center rounded text-xs sm:text-sm border border-gray-300 text-gray-600 hover:bg-gray-50"
    active_classes  = "min-w-8 h-8 px-2 inline-flex items-center justify-center rounded text-xs sm:text-sm bg-blue-500 text-white"
    disabled_classes = "min-w-8 h-8 px-2 inline-flex items-center justify-center rounded text-xs sm:text-sm border border-gray-200 text-gray-300"

    items = []

    items << (pagy.prev ? link_to("前へ", pagy_url_for(pagy, pagy.prev), class: link_classes)
                         : content_tag(:span, "前へ", class: disabled_classes))

    pagy.series.each do |item|
      items << case item
      when Integer
        link_to(item, pagy_url_for(pagy, item), class: link_classes)
      when String
        content_tag(:span, item, class: active_classes, aria: { current: "page" })
      when :gap
        content_tag(:span, "…", class: "min-w-8 h-8 px-1 inline-flex items-center justify-center text-xs sm:text-sm text-gray-400")
      end
    end

    items << (pagy.next ? link_to("次へ", pagy_url_for(pagy, pagy.next), class: link_classes)
                         : content_tag(:span, "次へ", class: disabled_classes))

    content_tag(:nav, safe_join(items), class: "flex items-center justify-center gap-1 mt-4", aria: { label: "pagination" })
  end
end

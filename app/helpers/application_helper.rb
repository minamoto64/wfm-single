module ApplicationHelper
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
    classes = %w[flex-1 text-center py-3 font-medium border-b-2]
    classes += active ? %w[border-blue-500 text-blue-600]
                      : %w[border-transparent text-gray-600 hover:text-gray-900]

    link_to tab[:path],
            class: classes,
            data:  { tabs_target: "tab", tab_name: tab[:name] } do
      tab[:label]
    end
  end
end

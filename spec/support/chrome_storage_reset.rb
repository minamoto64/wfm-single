require "capybara"

# Chrome 158 以降は、CDP の Storage.clearDataForOrigin に origin "*" を渡すと
# "invalid argument: * is not a valid URL" で拒否する。Capybara 3.40.0 の
# ChromeDriver#reset! は各 example の後に必ず "*" を渡すため、:js のシステムスペックが
# 後片付けでエラーになる（teamcapybara/capybara#2865）。
#
# "*" が拒否されたときだけ、Cookie はブラウザ全体、Local Storage はアプリのサーバーの
# origin に絞って消す。Chrome 157 以前では "*" が通るので、従来どおりの動作のまま。
#
# Capybara がこの問題を直したリリースを出したら、このファイルを削除する。
module ChromeStorageReset
  private

  def execute_cdp(cmd, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => e
    raise unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*" && e.message.include?("is not a valid URL")

    clear_storage_without_wildcard(params[:storageTypes].to_s.split(","))
  end

  def clear_storage_without_wildcard(storage_types)
    execute_cdp("Network.clearBrowserCookies") if storage_types.delete("cookies")
    return if storage_types.empty?

    origin = Capybara.app_host.presence || Capybara.current_session.server&.base_url
    execute_cdp("Storage.clearDataForOrigin", origin: origin, storageTypes: storage_types.join(",")) if origin
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)

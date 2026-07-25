require "rails_helper"

RSpec.describe "Interaction flow", type: :system do
  let(:user) { create(:user) }
  let!(:customer) { create(:customer) }

  def sign_in(user)
    visit login_path

    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(interactions_path)
  end

  # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
  it "logs in, creates an interaction with an image, and comments on it", :js do
    sign_in(user)

    visit new_interaction_path

    select customer.name, from: "顧客"
    select "電話", from: "問合せ種別"

    fill_in "応対日時", with: 1.hour.ago

    fill_in "要望内容", with: "商品について問い合わせがありました"
    fill_in "対応結果", with: "在庫を確認し折り返しました"
    attach_file "画像", Rails.root.join("spec/fixtures/files/test.jpg")

    click_button "登録"

    expect(page).to have_content("応対履歴詳細")
    expect(page).to have_content("商品について問い合わせがありました")
    expect(page).to have_content("在庫を確認し折り返しました")
    expect(page).to have_content("添付画像")

    fill_in "コメントを入力してください...", with: "対応ありがとうございます"
    click_button "コメントを投稿"

    expect(page).to have_content("対応ありがとうございます")
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end

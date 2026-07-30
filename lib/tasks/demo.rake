namespace :demo do
  desc "デモ環境のデータ(demo: true)を全削除し、初期シードを再投入する"
  task reset: :environment do
    ActiveRecord::Base.transaction do
      Comment.unscoped.where(demo: true).delete_all
      TaskAssignment.unscoped.where(demo: true).delete_all
      NoticeTask.where(notice: Notice.unscoped.where(demo: true)).delete_all
      InteractionTask.where(task: Task.unscoped.where(demo: true)).delete_all
      InteractionNotice.where(notice: Notice.unscoped.where(demo: true)).delete_all
      Task.unscoped.where(demo: true).delete_all
      Notice.unscoped.where(demo: true).delete_all
      Interaction.unscoped.where(demo: true).delete_all
      Customer.unscoped.where(demo: true).delete_all
      Session.where(user: User.unscoped.where(demo: true)).delete_all
      User.unscoped.where(demo: true).delete_all

      load Rails.root.join("db/seeds/demo_seed.rb")
    end

    puts "デモ環境のリセットが完了しました (#{Time.current})"
  end
end

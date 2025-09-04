class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    Cart.where(abandoned: false)
        .where("updated_at < ?", 3.hours.ago)
        .update_all(abandoned: true)

    Cart.where(abandoned: true)
        .where("updated_at < ?", 7.days.ago)
        .delete_all
  end
end

class SummaryController < ApplicationController

  def aact
    @updates = Public::Study.connection.execute("SELECT updated_at::date AS last_updated,
                                                count(*) AS number_of_studies
                                                from studies
                                                group by updated_at::date
                                                order by updated_at::date asc")

    @latest_event = Core::LoadEvent.where(event_type: ['incremental', 'full'], status: ['complete']).order(created_at: :desc).first
  end

end

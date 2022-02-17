class SummaryController < ApplicationController

  def aact
    @updates = Public::Study.connection.execute("SELECT updated_at::date AS last_updated,
                                        count(*) AS number_of_studies
                                        from studies
                                        group by updated_at::date
                                        order by updated_at::date asc"
                                        )
  end

end

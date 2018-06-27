require 'active_support/all'
class HealthCheck < ActiveRecord::Base

  def check_performance
    SampleQuery.check_performance.each{|sql|
      query = "(analyze, format yaml) " + sql
      db_mgr=Util::DbManager.new
      results=db_mgr.con.explain(query)
    }
  end

end

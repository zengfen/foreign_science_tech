class DataCentersController < ApplicationController

  def index
    @results = ArchonBase.table_metas
  end

end

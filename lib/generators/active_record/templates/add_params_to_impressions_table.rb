class AddParamsToImpressionsTable < ActiveRecord::Migration
  def change
    add_column :impressions, :params, :hstore
    add_column :impressions, :session, :hstore
  end
end
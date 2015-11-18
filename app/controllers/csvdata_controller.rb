require 'csv'
require 'open-uri'

class CsvdataController < ApplicationController

  def read

    # url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_shisetsuall.csv"
    url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_meisyo.csv"
    csv = open(url)
    @csv_obj = CSV.read(csv, encoding: "CP932:UTF-8", headers: :first_row)

    @csv_obj.each do |row|
      open_data = OpenDatum.find_by(shisetsu_id: row[19]) || OpenDatum.new
    end

  end

end

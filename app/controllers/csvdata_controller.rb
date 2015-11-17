require 'csv'
require 'open-uri'

class CsvdataController < ApplicationController

  def read

    url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_shisetsuall.csv"
    csv = open(url)
    @csv_obj = CSV.read(csv, encoding: "CP932:UTF-8", headers: :first_row)
  end

end

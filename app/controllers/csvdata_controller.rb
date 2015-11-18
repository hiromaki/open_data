require 'csv'
require 'open-uri'

class CsvdataController < ApplicationController

  def read

    url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_shisetsuall.csv"
    # url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_meisyo.csv"
    csv = open(url)
    @csv_obj = CSV.read(csv, encoding: "CP932:UTF-8", headers: :first_row)

    @csv_obj.each do |row|
      open_data = OpenDatum.find_by(shisetsu_id: row[19])

      # ファイルがなかった場合
      if open_data.nil?
        open_data = OpenDatum.new

        open_data.x = row[0]
        open_data.y = row[1]
        open_data.shisetsu_name = row[2]
        open_data.shisetsu_name_kana = row[3]
        open_data.shisetsu_name_all = row[4]
        open_data.syozaichi = row[5]
        open_data.chiku_name = row[6]
        open_data.tel = row[7]
        open_data.fax = row[8]
        open_data.syosai_info = row[9]
        open_data.kaikan_jikan = row[10]
        open_data.url = row[11]
        open_data.barrier_free_info = row[12]
        open_data.tyurinjyo_pc = row[13]
        open_data.tyurinjyo_kei = row[14]
        open_data.dai_bunrui = row[15]
        open_data.syo_bunrui = row[16]
        open_data.category = row[17]
        open_data.icon_no = row[18]
        open_data.shisetsu_id = row[19]
        open_data.latlng = row[0] + row[1]

        open_data.save

      else

        # open_data.x = row[0]
        # open_data.y = row[1]
        # open_data.shisetsu_name = row[2]
        # open_data.shisetsu_name_kana = row[3]
        # open_data.shisetsu_name_all = row[4]
        # open_data.syozaichi = row[5]
        # open_data.chiku_name = row[6]
        # open_data.tel = row[7]
        # open_data.fax = row[8]
        # open_data.syosai_info = row[9]
        # open_data.kaikan_jikan = row[10]
        # open_data.url = row[11]
        # open_data.barrier_free_info = row[12]
        # open_data.tyurinjyo_pc = row[13]
        # open_data.tyurinjyo_kei = row[14]
        # open_data.dai_bunrui = row[15]
        # open_data.syo_bunrui = row[16]
        # open_data.category = row[17]
        # open_data.icon_no = row[18]
        # open_data.shisetsu_id = row[19]
        # open_data.latlng = row[0] + row[1]

        # open_data.update


      end

    end

  end

end

require 'csv'
require 'open-uri'

class CsvdataController < ApplicationController

  def read

    input_category = "公衆トイレ/公衆便所"

    @csv_obj = Kaminari.paginate_array(OpenDatum.where(category: input_category)).page(params[:page]).per(10)

    # @csv_obj = OpenDatum.find_by(category: "公衆トイレ/公衆便所")
    # @csv_obj = OpenDatum.all

    if @csv_obj.blank?
      logger.debug("結果なし")
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

  end

  def insert

    # # 施設情報ポイントデータ（全体）
    # url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_shisetsuall.csv"

    # csv = open(url)
    # @csv_obj = CSV.read(csv, encoding: "CP932:UTF-8", headers: :first_row)

    # @csv_obj.each do |row|
    #   open_data = OpenDatum.find_by(shisetsu_id: row[19])

    #   # ファイルがなかった場合
    #   if open_data.nil?
    #     open_data = OpenDatum.new

    #     open_data.x = row[0]
    #     open_data.y = row[1]
    #     open_data.shisetsu_name = row[2]
    #     open_data.shisetsu_name_kana = row[3]
    #     open_data.shisetsu_name_all = row[4]
    #     open_data.syozaichi = row[5]
    #     open_data.chiku_name = row[6]
    #     open_data.tel = row[7]
    #     open_data.fax = row[8]
    #     open_data.syosai_info = row[9]
    #     open_data.kaikan_jikan = row[10]
    #     open_data.url = row[11]
    #     open_data.barrier_free_info = row[12]
    #     open_data.tyurinjyo_pc = row[13]
    #     open_data.tyurinjyo_kei = row[14]
    #     open_data.dai_bunrui = row[15]
    #     open_data.syo_bunrui = row[16]
    #     open_data.category = row[17]
    #     open_data.icon_no = row[18]
    #     open_data.shisetsu_id = row[19]
    #     open_data.latlng = row[0] + row[1]

    #     open_data.save

    #   end

    # end

    url_base = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/"

    urls = Array.new
    # 防災関連施設ポイントデータ（災害時避難所・一時避難場所）
    urls.push(url_base + "mapnavoskdat_hinanbasyo.csv")
    # 防災関連施設ポイントデータ（災害時用へリポート）
    # urls.push(url_base + "mapnavoskdat_heliport.csv")
    # # 防災関連施設ポイントデータ（防火水槽など）
    # urls.push(url_base + "mapnavoskdat_boukasuisou.csv")
    # # 防災関連施設ポイントデータ（防災スピーカー）
    # urls.push(url_base + "mapnavoskdat_bousaisp.csv")
    # # 防災関連施設ポイントデータ（津波避難ビル）
    # urls.push(url_base + "mapnavoskdat_hinanbiru.csv")

    for url in urls do

        if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/
            tmp_file = 'tmp\file_name'
        else
            tmp_file = "/tmp/file_name"
        end

        # csv = open(url, "rb:CP932:UTF-8").read.encode("utf-8", :invalid => :replace, :undef => :replace)
        csv = open(url, "r:binary").read.encode("CP932", "UTF-8", invalid: :replace, undef: :replace)
        File.open(tmp_file, 'wb') { |file| file.write(csv) }

        # @csv_obj = CSV.read('/tmp/file_name', encoding: "CP932:UTF-8", headers: :first_row)
        @csv_obj = CSV.read(tmp_file, encoding: "CP932:UTF-8", headers: :first_row)

        @csv_obj.each do |row|

          open_data = OpenDatum.find_by(shisetsu_id: row[8])

          # ファイルがなかった場合
          if open_data.nil?
            open_data = OpenDatum.new

            open_data.x = row[0]
            open_data.y = row[1]
            open_data.shisetsu_name = row[2]
            open_data.syozaichi = row[3]
            open_data.chiku_name = row[4]
            open_data.tel = row[5]
            open_data.syo_bunrui = row[6]
            open_data.category = row[7]
            open_data.shisetsu_id = row[8]
            open_data.latlng = row[0] + row[1]

            open_data.save

          end

        end

    end

  end

end

require 'csv'
require 'open-uri'

class Tasks::FacilityDataInsert
  def self.execute

    # bundle exec rails runner Tasks::FacilityDataInsert.execute
    # heroku run rails runner Tasks::FacilityDataInsert.execute

    Facility.delete_all

    # 施設情報ポイントデータ（全体）
    url = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/mapnavoskdat_shisetsuall.csv"

    csv = open(url)
    @csv_obj = CSV.read(csv, encoding: "UTF-8", headers: :first_row)

    @csv_obj.each do |row|
      facility = Facility.find_by(shisetsu_id: row[19])

      # DBにデータがない場合
      if facility.nil?
        facility = Facility.new

        facility.x = row[0]
        facility.y = row[1]
        facility.shisetsu_name = row[2]
        facility.shisetsu_name_kana = row[3]
        facility.shisetsu_name_all = row[4]
        facility.syozaichi = row[5]
        facility.chiku_name = row[6]
        facility.tel = row[7]
        facility.fax = row[8]
        facility.syosai_info = row[9]
        facility.kaikan_jikan = row[10]
        facility.url = row[11]
        facility.barrier_free_info = row[12]
        facility.tyurinjyo_pc = row[13]
        facility.tyurinjyo_kei = row[14]
        facility.dai_bunrui = row[15]
        facility.syo_bunrui = row[16]
        facility.category = row[17]
        facility.icon_no = row[18]
        facility.shisetsu_id = row[19]

        facility.save

      end

    end

    url_base = "http://www.city.osaka.lg.jp/contents/wdu090/opendata/mapnavoskdat_csv/"

    urls = Array.new
    urls.push(url_base + "mapnavoskdat_hinanbasyo.csv") # 防災関連施設ポイントデータ（災害時避難所・一時避難場所）
    urls.push(url_base + "mapnavoskdat_heliport.csv") # 防災関連施設ポイントデータ（災害時用へリポート）
    urls.push(url_base + "mapnavoskdat_boukasuisou.csv") # 防災関連施設ポイントデータ（防火水槽など）
    urls.push(url_base + "mapnavoskdat_bousaisp.csv") # 防災関連施設ポイントデータ（防災スピーカー）
    urls.push(url_base + "mapnavoskdat_hinanbiru.csv") # 防災関連施設ポイントデータ（津波避難ビル）

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

        facility = Facility.find_by(shisetsu_id: row[8])

        # DBにデータがない場合
        if facility.nil?

          facility = Facility.new

          if url == url_base + "mapnavoskdat_hinanbasyo.csv"
            facility.x = row[0]
            facility.y = row[1]
            facility.shisetsu_name = row[2]
            facility.syozaichi = row[3]
            facility.chiku_name = row[4]
            facility.tel = row[5]
            facility.syo_bunrui = row[6]
            facility.category = row[7]
            facility.shisetsu_id = row[8]
          elsif url == url_base + "mapnavoskdat_heliport.csv"
            facility.x = row[0]
            facility.y = row[1]
            facility.shisetsu_name = row[2]
            facility.syozaichi = row[3]
            facility.category = row[4]
            facility.shisetsu_id = row[5]
          elsif url == url_base + "mapnavoskdat_boukasuisou.csv"
            facility.x = row[0]
            facility.y = row[1]
            facility.shisetsu_name = row[2]
            facility.syozaichi = row[3]
            facility.chiku_name = row[4]
            facility.syo_bunrui = row[5]
            facility.category = row[6]
            facility.shisetsu_id = row[7]
          elsif url == url_base + "mapnavoskdat_bousaisp.csv"
            facility.x = row[0]
            facility.y = row[1]
            facility.shisetsu_name = row[2]
            facility.syozaichi = row[3]
            facility.syosai_info = row[4]
            facility.category = row[5]
            facility.shisetsu_id = row[6]
          elsif url == url_base + "mapnavoskdat_hinanbiru.csv"
            facility.x = row[0]
            facility.y = row[1]
            facility.shisetsu_name = row[2]
            facility.syozaichi = row[3]
            facility.tel = row[4]
            facility.syosai_info = row[5]
            facility.category = row[6]
            facility.shisetsu_id = row[7]
          end

          facility.save

        end

      end

    end

    # 地区がnullのデータをその他にする
    Facility.where("chiku_name is null").update_all("chiku_name = 'その他'")

    # 基データで地区が何故かその他になっているものは、所在地の住所に地区を修正する
    Chiku.all.each do |chiku|
      Facility.where("chiku_name = 'その他' and syozaichi like '%#{chiku.name}%' ").update_all("chiku_name = '#{chiku.name}'")
    end

    # 個別対応
    Facility.where("chiku_name = 'その他' and shisetsu_name = '淀川河川敷太子橋' ").update_all("chiku_name = '旭区'")
    Facility.where("chiku_name = 'その他' and shisetsu_name = '旭公園野球場' ").update_all("chiku_name = '旭区'")
    Facility.where("chiku_name = 'その他' and shisetsu_name = 'グランフロント大阪　南館' ").update_all("chiku_name = '北区'")
    Facility.where("chiku_name = 'その他' and shisetsu_name = '神崎川日光ハイツ' ").update_all("chiku_name = '大阪市以外'")

    # 名称が不明の施設
    Facility.where("shisetsu_name is null ").update_all("shisetsu_name = '施設名称不明'")

  end
end

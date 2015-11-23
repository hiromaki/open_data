class CsvdataController < ApplicationController

  def read

    input_category = "その他"

    buttons = set_buttons

    buttons.each do |key, value|

        if key
            input_category = value
            break
        end

    end

    @csv_obj = Kaminari.paginate_array(OpenDatum.where("category like '%" + input_category + "%'")).page(params[:page]).per(10)

    # @csv_obj = OpenDatum.find_by(category: "") 一件
    # @csv_obj = OpenDatum.all 全件

    if @csv_obj.blank?
      logger.debug("結果なし")
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @hash = Gmaps4rails.build_markers(@csv_obj) do |csv, marker|
      marker.lat csv.y
      marker.lng csv.x
      marker.infowindow csv.shisetsu_name
      marker.json({title: csv.shisetsu_name})
    end

    @chiku_list = Array.new
 
    @chiku_list.push("都島区")
    @chiku_list.push("福島区")
    @chiku_list.push("此花区")
    @chiku_list.push("西区")
    @chiku_list.push("港区")
    @chiku_list.push("大正区")
    @chiku_list.push("天王寺区")
    @chiku_list.push("浪速区")
    @chiku_list.push("西淀川区")
    @chiku_list.push("東淀川区")
    @chiku_list.push("東成区")
    @chiku_list.push("生野区")
    @chiku_list.push("旭区")
    @chiku_list.push("城東区")
    @chiku_list.push("阿倍野区")
    @chiku_list.push("住吉区")
    @chiku_list.push("東住吉区")
    @chiku_list.push("西成区")
    @chiku_list.push("淀川区")
    @chiku_list.push("鶴見区")
    @chiku_list.push("住之江区")
    @chiku_list.push("平野区")
    @chiku_list.push("北区")
    @chiku_list.push("中央区")
    @chiku_list.push("その他")
 
  end

  def set_buttons

    buttons = Hash.new
    buttons.store(params[:sonota_button],  "その他")
    buttons.store(params[:sonota_shisetsu_button],  "その他/その他施設")
    buttons.store(params[:musen_lan_spot_button],  "その他/無線LANスポット")
    buttons.store(params[:iryo_fukushi_button],  "医療・福祉")
    buttons.store(params[:kaigo_rojin_hoken_button],  "医療・福祉/介護老人保健施設")
    buttons.store(params[:tokubetsu_yougo_rojin_button],  "医療・福祉/特別養護老人ホーム")
    buttons.store(params[:byoin_shinryojyo_button],  "医療・福祉/病院・診療所")
    buttons.store(params[:fukushi_shisetsu_button],  "医療・福祉/福祉施設")
    buttons.store(params[:eki_bustei_button],  "駅・バス停")
    buttons.store(params[:bustei_button],  "駅・バス停/バス停")
    buttons.store(params[:eki_button],  "駅・バス停/駅")
    buttons.store(params[:kaikan_hole_button],  "会館・ホール")
    buttons.store(params[:kaikan_hole_button],  "会館・ホール/会館・ホール")
    buttons.store(params[:chiiki_syukaisyo_rojin_ikoino_ie_button],  "会館・ホール/地域集会所・老人憩いの家")
    buttons.store(params[:gakko_hoikusyo_button],  "学校・保育所")
    buttons.store(params[:gakko_sonota_button],  "学校・保育所/学校(その他)")
    buttons.store(params[:kouto_gakko_button],  "学校・保育所/高等学校")
    buttons.store(params[:syo_gakko_button],  "学校・保育所/小学校")
    buttons.store(params[:daigaku_button],  "学校・保育所/大学")
    buttons.store(params[:chugakko_button],  "学校・保育所/中学校")
    buttons.store(params[:hoikusyo_button],  "学校・保育所/保育所")
    buttons.store(params[:yochien_button],  "学校・保育所/幼稚園")
    buttons.store(params[:kankoucho_button],  "官公庁")
    buttons.store(params[:kunino_kikan_button],  "官公庁/国の機関")
    buttons.store(params[:shi_kikan_button],  "官公庁/市の機関")
    buttons.store(params[:fu_kikan_button],  "官公庁/府の機関")
    buttons.store(params[:kankyo_recycle_button],  "環境・リサイクル")
    buttons.store(params[:furukami_kaisyu_kyoryokuten_button],  "環境・リサイクル/古紙回収協力店")
    buttons.store(params[:keisatsu_syobo_button],  "警察・消防")
    buttons.store(params[:keisatus_koban_button],  "警察・消防/警察・交番")
    buttons.store(params[:syobosyo_button],  "警察・消防/消防署")
    buttons.store(params[:koen_sports_button],  "公園・スポーツ")
    buttons.store(params[:sports_shisetsu_button],  "公園・スポーツ/スポーツ施設")
    buttons.store(params[:koen_button],  "公園・スポーツ/公園")
    buttons.store(params[:jido_koen_hiroba_button],  "公園・スポーツ/児童遊園・広場")
    buttons.store(params[:kosyu_toilet_button],  "公衆トイレ")
    buttons.store(params[:kosyu_benjyo_button],  "公衆トイレ/公衆便所")
    buttons.store(params[:kurumaisu_taio_kosyu_benjyo_button],  "公衆トイレ/車いす対応公衆便所")
    buttons.store(params[:tyusyajyo_tyurinjyo_button],  "駐車場・駐輪場")
    buttons.store(params[:bike_tyusyajyo_button],  "駐車場・駐輪場/バイク駐車場")
    buttons.store(params[:ekisyuhen_tyurinjyo_button],  "駐車場・駐輪場/駅周辺駐輪場")
    buttons.store(params[:ekisyuhen_tyurinjyo_sonota_button],  "駐車場・駐輪場/駅周辺駐輪場（その他）")
    buttons.store(params[:jitensya_hokanjyo_button],  "駐車場・駐輪場/自転車保管所")
    buttons.store(params[:bunka_kanko_button],  "文化・観光")
    buttons.store(params[:bunka_kanko_sonota_button],  "文化・観光/その他施設")
    buttons.store(params[:tosyokan_button],  "文化・観光/図書館")
    buttons.store(params[:toshi_keikan_shigen_button],  "文化・観光/都市景観資源")
    buttons.store(params[:bijyutsukan_hakubutsukan_button],  "文化・観光/美術館・博物館")
    buttons.store(params[:meisyo_kyuseki_button],  "名所・旧跡")
    buttons.store(params[:syaji_button],  "名所・旧跡/社寺")
    buttons.store(params[:meisyo_kyuseki_syosai_button],  "名所・旧跡/名所・旧跡")

    return buttons

  end

end

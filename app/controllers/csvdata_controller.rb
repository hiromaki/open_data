class CsvdataController < ApplicationController

  def read

    input_category = "その他"

    buttons = setButtons

    for button in buttons do

        if button
            input_category = button
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

  end

private

  def setButtons

    buttons = Array.new
    buttons.push(params[:sonota_button])
    buttons.push(params[:sonota_shisetsu_button])
    buttons.push(params[:musen_lan_spot_button])
    buttons.push(params[:iryo_fukushi_button])
    buttons.push(params[:kaigo_rojin_hoken_button])
    buttons.push(params[:tokubetsu_yougo_rojin_button])
    buttons.push(params[:byoin_shinryojyo_button])
    buttons.push(params[:fukushi_shisetsu_button])
    buttons.push(params[:eki_bustei_button])
    buttons.push(params[:bustei_button])
    buttons.push(params[:eki_button])
    buttons.push(params[:kaikan_hole_button])
    buttons.push(params[:kaikan_hole_button])
    buttons.push(params[:chiiki_syukaisyo_rojin_ikoino_ie_button])
    buttons.push(params[:gakko_hoikusyo_button])
    buttons.push(params[:gakko_sonota_button])
    buttons.push(params[:kouto_gakko_button])
    buttons.push(params[:syo_gakko_button])
    buttons.push(params[:daigaku_button])
    buttons.push(params[:chugakko_button])
    buttons.push(params[:hoikusyo_button])
    buttons.push(params[:yochien_button])
    buttons.push(params[:kankoucho_button])
    buttons.push(params[:kunino_kikan_button])
    buttons.push(params[:shi_kikan_button])
    buttons.push(params[:fu_kikan_button])
    buttons.push(params[:kankyo_recycle_button])
    buttons.push(params[:furukami_kaisyu_kyoryokuten_button])
    buttons.push(params[:keisatsu_syobo_button])
    buttons.push(params[:keisatus_koban_button])
    buttons.push(params[:syobosyo_button])
    buttons.push(params[:koen_sports_button])
    buttons.push(params[:sports_shisetsu_button])
    buttons.push(params[:koen_button])
    buttons.push(params[:jido_koen_hiroba_button])
    buttons.push(params[:kosyu_toilet_button])
    buttons.push(params[:kosyu_benjyo_button])
    buttons.push(params[:kurumaisu_taio_kosyu_benjyo_button])
    buttons.push(params[:tyusyajyo_tyurinjyo_button])
    buttons.push(params[:bike_tyusyajyo_button])
    buttons.push(params[:ekisyuhen_tyurinjyo_button])
    buttons.push(params[:ekisyuhen_tyurinjyo_sonota_button])
    buttons.push(params[:jitensya_hokanjyo_button])
    buttons.push(params[:bunka_kanko_button])
    buttons.push(params[:bunka_kanko_sonota_button])
    buttons.push(params[:tosyokan_button])
    buttons.push(params[:toshi_keikan_shigen_button])
    buttons.push(params[:bijyutsukan_hakubutsukan_button])
    buttons.push(params[:meisyo_kyuseki_button])
    buttons.push(params[:syaji_button])
    buttons.push(params[:meisyo_kyuseki_syosai_button])

  end

end

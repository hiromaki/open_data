class FacilityController < ApplicationController

  def search

    logger.debug("readを実行")

    @chiku_array = Array.new{ Array.new(2)}

    chikus = Chiku.all

    if params[:category].nil?
      @csv_obj = Kaminari.paginate_array(Facility.all).page(params[:page]).per(10)

      chikus.each do |chiku|
        @chiku_array.push([chiku.name, true])
      end

    else
      if params[:category] == ""
        @csv_obj = Kaminari.paginate_array(Facility.where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(10)
      else
        @csv_obj = Kaminari.paginate_array(Facility.where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%'").where("category like '" + params[:category] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(10)
      end
      @shisetsu_name_value = params[:text][:shisetsu_name]
      @category_selected = params[:category]

      chikus.each do |chiku|
        @chiku_array.push([chiku.name, check_hantei(params[:check][:chikus], chiku.name)])
      end

    end

    if @csv_obj.blank?
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @hash = gmap_hash(@csv_obj)

  end

  def check_hantei(chiku_array, target_chiku)

    if chiku_array.index(target_chiku).nil?
        return false
    else
        return true
    end

  end

  def gmap_hash(obj)

    hash = Gmaps4rails.build_markers(obj) do |csv, marker|
      marker.lat csv.y
      marker.lng csv.x
      marker.infowindow csv.shisetsu_name
      marker.json({title: csv.shisetsu_name})
    end

  end

end

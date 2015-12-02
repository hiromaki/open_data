class FacilityController < ApplicationController

  def index

    @chiku_array = Array.new{ Array.new(2)}
    chikus = Chiku.all

    if params[:category].nil?
      @facilities = Kaminari.paginate_array(Facility.all).page(params[:page]).per(10)

      chikus.each do |chiku|
        @chiku_array.push([chiku.name, true])
      end

    else
      if params[:category] == ""
        @facilities = Kaminari.paginate_array(Facility.where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(10)
      else
        @facilities = Kaminari.paginate_array(Facility.where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%'").where("category like '" + params[:category] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(10)
      end
      @shisetsu_name_value = params[:text][:shisetsu_name]
      @category_selected = params[:category]

      chikus.each do |chiku|
        @chiku_array.push([chiku.name, chiku_checkbox(params[:check][:chikus], chiku.name)])
      end

    end

    if @facilities.blank?
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @gmap_hash = gmap_hash(@facilities)

  end

  def show

    index
    @facility = Facility.find(params[:id])
  end

  def chiku_checkbox(chiku_array, target_chiku)

    if chiku_array.index(target_chiku).nil?
        return false
    else
        return true
    end

  end

  def gmap_hash(facilities)

    hash = Gmaps4rails.build_markers(facilities) do |facility, marker|
      marker.lat csv.y
      marker.lng csv.x
      marker.infowindow facility.shisetsu_name
      marker.json({title: facility.shisetsu_name})
    end

  end

end

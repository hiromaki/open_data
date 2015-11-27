class CsvdataController < ApplicationController

  def init

    input_category = ""

    @csv_obj = Kaminari.paginate_array(OpenDatum.all).page(params[:page]).per(10)

    if @csv_obj.blank?
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @hash = gmap_hash(@csv_obj)

    @chiku_array = Array.new{ Array.new(2)}

    chikus = Chiku.all

    chikus.each do |chiku|
        @chiku_array.push([chiku.name, true])
    end

    @categories = Category.all

    render "read"

  end

  def read


    input_category = String.new

    @categories = Category.all

    @categories.each do |category|
        if category.param_name == params[:submit_button]
            input_category = category.db_name
            break
        end
    end

    if input_category == "全部"
        @csv_obj = Kaminari.paginate_array(OpenDatum.where("shisetsu_name like '%" + params[:shisetsu_name][:shisetsu_name] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(10)
    else
        @csv_obj = Kaminari.paginate_array(OpenDatum.where("shisetsu_name like '%" + params[:shisetsu_name][:shisetsu_name] + "%'").where("category like '%" + input_category + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(10)
    end

    if @csv_obj.blank?
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @hash = gmap_hash(@csv_obj)

    @chiku_array = Array.new{ Array.new(2)}

    chikus = Chiku.all

    chikus.each do |chiku|
        @chiku_array.push([chiku.name, check_hantei(params[:check][:chikus], chiku.name)])
    end

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

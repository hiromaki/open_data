class FacilityController < ApplicationController

  def index

    flash.now[:notice] = "検索条件を入力のうえ、検索をしてください。"

    chiku_array = Array.new{ Array.new(2)}

    @facilities = Kaminari.paginate_array(Facility.order("category, chiku_name").all).page(params[:page]).per(10)

    chiku_all_check = true
    Chiku.all.each do |chiku|
      chiku_array.push([chiku.name, true])
    end

    if @facilities.blank?
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @gmap_hash = gmap_hash(@facilities)

    search_param = Hash.new
    search_param[:chiku_array] = chiku_array
    search_param[:chiku_all_check] = chiku_all_check
    search_param[:category_selected] = ""
    search_param[:shisetsu_name] = ""
    search_param[:row_count] = 10
    @search_param = search_param
    session["search_param"] = @search_param

  end

  def search

    chiku_array = Array.new{ Array.new(2)}

    if params[:category].blank?
      @facilities = Kaminari.paginate_array(Facility.order("category, chiku_name").where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%' or shisetsu_name_kana like '%" + params[:text][:shisetsu_name] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(params[:row_count])
    else
      @facilities = Kaminari.paginate_array(Facility.order("category, chiku_name").where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%' or shisetsu_name_kana like '%" + params[:text][:shisetsu_name] + "%'").where("category like '" + params[:category] + "%'").where(chiku_name: params[:check][:chikus])).page(params[:page]).per(params[:row_count])
    end
    shisetsu_name_value = params[:text][:shisetsu_name]
    category_selected = params[:category]

    chiku_all_check = true
    Chiku.all.each do |chiku|
      chiku_array.push([chiku.name, chiku_checkbox(params[:check][:chikus], chiku.name)])
      chiku_all_check = false unless chiku_checkbox(params[:check][:chikus], chiku.name)
    end

    if @facilities.blank?
      flash.now[:alert] = "検索結果が存在しませんでした。"
    end

    @gmap_hash = gmap_hash(@facilities)

    search_param = Hash.new
    search_param[:chiku_array] = chiku_array
    search_param[:chiku_all_check] = chiku_all_check
    search_param[:category_selected] = category_selected
    search_param[:shisetsu_name] = shisetsu_name_value
    search_param[:row_count] = params[:row_count]
    @search_param = search_param
    session["search_param"] = @search_param

    render "index"

  end

  def show

    # 一度セッションに入れるとシンボルが文字列に変わるため
    @search_param = session["search_param"].symbolize_keys!
    @facility = Facility.find(params[:id])
    @gmap_hash = gmap_hash(@facility)

  end

  private

  def side_bar(init)
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
      marker.lat facility.y
      marker.lng facility.x
      marker.infowindow facility.shisetsu_name
      marker.json({title: facility.shisetsu_name})
    end

  end

end

class FacilityController < ApplicationController

  def index
    flash.now[:notice] = Constants::INITIAL_DISPLAY_MESSAGE # 初期メッセージ
    # 検索パラメータ
    @search_param = set_search_param("", Constants::INITIAL_DISPLAY_NUMBER, Constants::INITIAL_LATITUDE, Constants::INITIAL_LONGITUDE, "", "", params[:page])
    session["search_param"] = @search_param
    # 検索処理
    @facilities, @gmap_hash = select(@search_param)
  end

  def search
    if params[:authenticity_token].present?
      @search_param = set_search_param(params[:category], params[:row_count], params[:latitude], params[:longitude], params[:address], params[:sort][:conditions], params[:page])
      if @search_param[:latitude].nil?
        flash.now[:alert] = "指定住所が正しくありません。"
        render "index" and return
      end
      session["search_param"] = @search_param
    else
      @search_param = session["search_param"].symbolize_keys!
    end
    # 検索処理
    @facilities, @gmap_hash = select(@search_param)
    render "index"
  end

  def show
    # 一度セッションに入れるとシンボルが文字列に変わるため
    @search_param = session["search_param"].symbolize_keys!
    @facility = Facility.find(params[:id])
    @gmap_hash = set_gmap_hash(@facility,nil,nil)
  end

  private

  def select(param)
    facilities_model = Facility.by_distance(:origin =>[param[:latitude],param[:longitude]], :reverse => false)
    facilities_model = facilities_model.where("category like '" + param[:category] + "%'") if param[:category].present? # 条件により動的に変更する検索条件
    facilities = Kaminari.paginate_array(facilities_model).page(param[:page]).per(param[:row_count])

    gmap_hash = set_gmap_hash(facilities, param[:latitude],param[:longitude])
    flash.now[:alert] = Constants::SEARCH_RESULTS_ZERO if facilities.blank?
    return facilities, gmap_hash
  end

  def set_search_param(category_selected, row_count, latitude, longitude, address, sort_conditions, page)
    search_param = Hash.new

    search_param[:page] = page

    search_param[:category_selected] = category_selected
    search_param[:row_count] = row_count
    search_param[:latitude] = latitude
    search_param[:longitude] = longitude
    search_param[:address] = address
    search_param[:sort_conditions] = sort_conditions

    search_param[:sort_conditions_shiteinashi] = false
    search_param[:sort_conditions_genzaichi] = false
    search_param[:sort_conditions_shiteijyusyo] = false

    if sort_conditions == "" # indexから来た場合
      search_param[:sort_conditions_shiteinashi] = true
    else
      if sort_conditions == "0"
        search_param[:sort_conditions_shiteinashi] = true
        search_param[:latitude] = Constants::INITIAL_LATITUDE
        search_param[:longitude] = Constants::INITIAL_LONGITUDE
      elsif sort_conditions == "1"
        search_param[:sort_conditions_genzaichi] = true
      elsif sort_conditions == "2"
        search_param[:sort_conditions_shiteijyusyo] = true
        Geocoder.configure(:language  => :ja,  :units => :km )
        result = Geocoder.search(search_param[:address])
        if result.empty?
          search_param[:latitude] = nil
          search_param[:longitude] = nil
        else
          search_param[:latitude] = result[0].data["geometry"]["location"]["lat"]
          search_param[:longitude] = result[0].data["geometry"]["location"]["lng"]
        end
      end
    end

    return search_param
  end

  def set_gmap_hash(facilities, origin_lat, origin_lng)
    hash = Gmaps4rails.build_markers(facilities) do |facility, marker|
      marker.lat facility.y
      marker.lng facility.x
      marker.infowindow facility.shisetsu_name
    end

    unless origin_lat.nil?
      origin = {
        :lat => origin_lat,
        :lng => origin_lng,
        :infowindow => '起点',
      }
      hash.push(origin)
    end
    return hash
  end

end

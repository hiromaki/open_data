class FacilityController < ApplicationController

  def index

    # メッセージ
    flash.now[:notice] = Constants::INITIAL_DISPLAY_MESSAGE

    lat = Constants::INITIAL_LATITUDE
    lng = Constants::INITIAL_LONGITUDE

    @facilities = Kaminari.paginate_array(
                    Facility.all.by_distance(:origin =>[lat, lng], :reverse => false)
                    .order("category, chiku_name")
                  ).page(params[:page]).per(Constants::INITIAL_DISPLAY_NUMBER)

    flash.now[:alert] = Constants::SEARCH_RESULTS_ZERO if @facilities.blank?

    @gmap_hash = set_gmap_hash(@facilities, lat, lng)

    @search_param = set_search_param("", Constants::INITIAL_DISPLAY_NUMBER, "", "", "", "")
    session["search_param"] = @search_param

  end

  def search

    Geocoder.configure(:language  => :ja,  :units => :km )

    if params[:authenticity_token].present?
      @search_param = set_search_param(params[:category], params[:row_count], params[:latitude], params[:longitude], params[:address], params[:sort][:conditions])
      session["search_param"] = @search_param
    else
      @search_param = session["search_param"].symbolize_keys!
    end

    if @search_param[:sort_conditions_shiteinashi]
      lat = Constants::INITIAL_LATITUDE
      lng = Constants::INITIAL_LONGITUDE
    elsif @search_param[:sort_conditions_genzaichi]
      lat = @search_param[:latitude]
      lng = @search_param[:longitude]
    else
      result = Geocoder.search(@search_param[:address])
      if result.empty?
        # redirect_to(:back)
        flash.now[:alert] = "指定住所が正しくありません。"
        render "index" and return
      end
      lat = result[0].data["geometry"]["location"]["lat"]
      lng = result[0].data["geometry"]["location"]["lng"]
    end

    facilities_model = Facility.by_distance(:origin =>[lat,lng], :reverse => false)

    # 条件により動的に変更する検索条件
    facilities_model = facilities_model.where("category like '" + @search_param[:category] + "%'") if @search_param[:category].present?

    @facilities = Kaminari.paginate_array(facilities_model).page(params[:page]).per(@search_param[:row_count])
    @gmap_hash = set_gmap_hash(@facilities, lat, lng)

    flash.now[:alert] = Constants::SEARCH_RESULTS_ZERO if @facilities.blank?

    render "index"

  end

  def show
    # 一度セッションに入れるとシンボルが文字列に変わるため
    @search_param = session["search_param"].symbolize_keys!
    @facility = Facility.find(params[:id])
    @gmap_hash = set_gmap_hash(@facility,nil,nil)
  end

  private

  def set_search_param(category_selected, row_count, latitude, longitude, address, sort_conditions)
    search_param = Hash.new
      search_param[:category_selected] = category_selected
    search_param[:row_count] = row_count
    search_param[:latitude] = latitude
    search_param[:longitude] = longitude
    search_param[:address] = address
    search_param[:sort_conditions] = sort_conditions
    if sort_conditions == "0"
      search_param[:sort_conditions_shiteinashi] = true
      search_param[:sort_conditions_genzaichi] = false
      search_param[:sort_conditions_shiteijyusyo] = false
    elsif sort_conditions == "1"
      search_param[:sort_conditions_shiteinashi] = false
      search_param[:sort_conditions_genzaichi] = true
      search_param[:sort_conditions_shiteijyusyo] = false
    elsif sort_conditions == "2"
      search_param[:sort_conditions_shiteinashi] = false
      search_param[:sort_conditions_genzaichi] = false
      search_param[:sort_conditions_shiteijyusyo] = true
    elsif sort_conditions == ""
      search_param[:sort_conditions_shiteinashi] = true
      search_param[:sort_conditions_genzaichi] = false
      search_param[:sort_conditions_shiteijyusyo] = false
    end
    return search_param
  end

  def set_gmap_hash(facilities, origin_lat, origin_lng)

    hash = Gmaps4rails.build_markers(facilities) do |facility, marker|
      marker.lat facility.y
      marker.lng facility.x
      marker.infowindow facility.shisetsu_name
      marker.json({title: facility.shisetsu_name})
    end

    hash = Gmaps4rails.build_markers(facilities) do |facility, marker|
      marker.lat facility.y
      marker.lng facility.x
      marker.infowindow facility.shisetsu_name
      marker.json({title: facility.shisetsu_name}) # ここ要らないかも
    end

    unless origin_lat.nil?

      pic = ActionController::Base.helpers.asset_path "ajax-loader.gif"

      origin = {
        :lat => origin_lat,
        :lng => origin_lng,
        :infowindow => '起点',
        :title => '起点' # ここ要らないかも
      }
      hash.push(origin)
    end

    return hash

  end

end

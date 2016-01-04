class FacilityController < ApplicationController

  def index

    flash.now[:notice] = Constants::INITIAL_DISPLAY_MESSAGE

    @facilities = Kaminari.paginate_array(
                    Facility.all.by_distance(:origin =>[Constants::INITIAL_LATITUDE, Constants::INITIAL_LONGITUDE], :reverse => false)
                    .order("category, chiku_name")
                  ).page(params[:page]).per(Constants::INITIAL_DISPLAY_NUMBER)

    chiku_array = Array.new{ Array.new(2)}
    # Chiku.all.each do |chiku|
    #   chiku_array.push([chiku.name, true])
    # end

    flash.now[:alert] = Constants::SEARCH_RESULTS_ZERO if @facilities.blank?

    @gmap_hash = set_gmap_hash(@facilities, Constants::INITIAL_LATITUDE, Constants::INITIAL_LONGITUDE)

    @search_param = set_search_param(chiku_array, true, "", "", Constants::INITIAL_DISPLAY_NUMBER, false, "", "", "", "")
    session["search_param"] = @search_param

  end

  def search

    Geocoder.configure(:language  => :ja,  :units => :km )
    logger.debug(params[:address])

    result = Geocoder.search(params[:address])

    lat = Constants::INITIAL_LATITUDE
    lng = Constants::INITIAL_LONGITUDE

    @search_param = set_search_param(set_chiku_array, set_chiku_all_check, params[:category], "",
                                       params[:row_count], "", params[:latitude], params[:longitude], params[:address], params[:sort][:conditions])

    session["search_param"] = @search_param


# logger.debug(params[:sort][:conditions])

    # あとでなおす
    if params[:sort][:conditions] == "0"
      lat = Constants::INITIAL_LATITUDE
      lng = Constants::INITIAL_LONGITUDE
    elsif params[:sort][:conditions] == "1"
      lat = params[:latitude]
      lng = params[:longitude]
    else
      if result.empty?
        logger.debug("情報が取得できない")
        # redirect_to(:back)
        flash.now[:alert] = "指定住所が正しくありません。"
        render "index" and return
      end
      logger.debug(Geocoder.search(params[:address])[0].data["formatted_address"])
      lat = result[0].data["geometry"]["location"]["lat"]
      lng = result[0].data["geometry"]["location"]["lng"]
    end



    # if params[:chikaijyun_check]
    #   lat = params[:latitude]
    #   lng = params[:longitude]
    # end

    # unless result.empty?
    #   logger.debug(Geocoder.search(params[:text][:address])[0].data["formatted_address"])
    #   # lat = result[0].data["geometry"]["location"]["lat"]
    #   # lng = result[0].data["geometry"]["location"]["lng"]
    # end

    facilities_model = Facility.by_distance(:origin =>[lat,lng], :reverse => false)

    # if params[:chikaijyun_check]
    #   facilities_model = Facility.by_distance(:origin =>[lat,lng], :reverse => false) if params[:chikaijyun_check]
    # else
    #   facilities_model = Facility.order("category, chiku_name")
    # end

    # facilities_model = facilities_model.where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%' or shisetsu_name_kana like '%" + params[:text][:shisetsu_name] + "%'")
    # facilities_model = facilities_model.where(chiku_name: params[:check][:chikus])

    # 条件により動的に変更する検索条件
    facilities_model = facilities_model.where("category like '" + params[:category] + "%'") if params[:category].present?

    @facilities = Kaminari.paginate_array(facilities_model).page(params[:page]).per(params[:row_count])
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

  def autocomplete_facility
    facility_suggestions = Facility.autocomplete(params[:term]).pluck(:shisetsu_name)
    respond_to do |format|
      format.html
      format.json {
        render json: facility_suggestions
      }
    end
  end

  private

  def set_search_param(chiku_array, chiku_all_check, category_selected, shisetsu_name, row_count, chikaijyun_check, latitude, longitude, address, sort_conditions)

    search_param = Hash.new
    # search_param[:chiku_array] = chiku_array
    # search_param[:chiku_all_check] = chiku_all_check
    search_param[:category_selected] = category_selected
    # search_param[:shisetsu_name] = shisetsu_name
    search_param[:row_count] = row_count
    # search_param[:chikaijyun_check] = chikaijyun_check
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

  def set_chiku_array
    # chiku_array = Array.new{ Array.new(2)}
    # Chiku.all.each do |chiku|
    #   chiku_array.push([chiku.name, chiku_checkbox(params[:check][:chikus], chiku.name)])
    # end
    # return chiku_array
  end

  def set_chiku_all_check
    # chiku_all_check = true
    # Chiku.all.each do |chiku|
    #   chiku_all_check = false unless chiku_checkbox(params[:check][:chikus], chiku.name)
    # end
    # return chiku_all_check
  end


  def chiku_checkbox(chiku_array, target_chiku)
    return chiku_array.index(target_chiku).nil? ? false : true
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

    logger.debug(hash)

    return hash

  end

end

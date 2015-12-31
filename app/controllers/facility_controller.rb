class FacilityController < ApplicationController

  def index

    flash.now[:notice] = Constants::INITIAL_DISPLAY_MESSAGE

    @facilities = Kaminari.paginate_array(
                    Facility.all.by_distance(:origin =>[Constants::INITIAL_LATITUDE, Constants::INITIAL_LONGITUDE], :reverse => false)
                    .order("category, chiku_name")
                  ).page(params[:page]).per(Constants::INITIAL_DISPLAY_NUMBER)

    chiku_array = Array.new{ Array.new(2)}
    Chiku.all.each do |chiku|
      chiku_array.push([chiku.name, true])
    end

    flash.now[:alert] = Constants::SEARCH_RESULTS_ZERO if @facilities.blank?

    @gmap_hash = set_gmap_hash(@facilities)

    @search_param = set_search_param(chiku_array, true, "", "", Constants::INITIAL_DISPLAY_NUMBER, false, "", "", "")
    session["search_param"] = @search_param

  end

  def search

    Geocoder.configure(:language  => :ja,  :units => :km )
    logger.debug(params[:text][:address])

    result = Geocoder.search(params[:text][:address])

    lat = Constants::INITIAL_LATITUDE
    lng = Constants::INITIAL_LONGITUDE

    if params[:chikaijyun_check]
      lat = params[:latitude]
      lng = params[:longitude]
    end

    unless result.empty?
      logger.debug(Geocoder.search(params[:text][:address])[0].data["formatted_address"])
      lat = result[0].data["geometry"]["location"]["lat"]
      lng = result[0].data["geometry"]["location"]["lng"]
    end

    facilities_model = Facility.by_distance(:origin =>[lat,lng], :reverse => false)

    # if params[:chikaijyun_check]
    #   facilities_model = Facility.by_distance(:origin =>[lat,lng], :reverse => false) if params[:chikaijyun_check]
    # else
    #   facilities_model = Facility.order("category, chiku_name")
    # end

    facilities_model = facilities_model.where("shisetsu_name like '%" + params[:text][:shisetsu_name] + "%' or shisetsu_name_kana like '%" + params[:text][:shisetsu_name] + "%'")
    facilities_model = facilities_model.where(chiku_name: params[:check][:chikus])

    # 条件により動的に変更する検索条件
    facilities_model = facilities_model.where("category like '" + params[:category] + "%'") if params[:category].present?

    @facilities = Kaminari.paginate_array(facilities_model).page(params[:page]).per(params[:row_count])

    flash.now[:alert] = Constants::SEARCH_RESULTS_ZERO if @facilities.blank?

    @gmap_hash = set_gmap_hash(@facilities)

    @search_param = set_search_param(set_chiku_array, set_chiku_all_check, params[:category], params[:text][:shisetsu_name],
                                       params[:row_count], params[:chikaijyun_check], params[:latitude], params[:longitude], params[:text][:address])
    session["search_param"] = @search_param

    render "index"

  end

  def show

    # 一度セッションに入れるとシンボルが文字列に変わるため
    @search_param = session["search_param"].symbolize_keys!
    @facility = Facility.find(params[:id])
    @gmap_hash = set_gmap_hash(@facility)

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

  def set_search_param(chiku_array, chiku_all_check, category_selected, shisetsu_name, row_count, chikaijyun_check, latitude, longitude, address)

    search_param = Hash.new
    search_param[:chiku_array] = chiku_array
    search_param[:chiku_all_check] = chiku_all_check
    search_param[:category_selected] = category_selected
    search_param[:shisetsu_name] = shisetsu_name
    search_param[:row_count] = row_count
    search_param[:chikaijyun_check] = chikaijyun_check
    search_param[:latitude] = latitude
    search_param[:longitude] = longitude
    search_param[:address] = address

    return search_param

  end

  def set_chiku_array
    chiku_array = Array.new{ Array.new(2)}
    Chiku.all.each do |chiku|
      chiku_array.push([chiku.name, chiku_checkbox(params[:check][:chikus], chiku.name)])
    end
    return chiku_array
  end

  def set_chiku_all_check
    chiku_all_check = true
    Chiku.all.each do |chiku|
      chiku_all_check = false unless chiku_checkbox(params[:check][:chikus], chiku.name)
    end
    return chiku_all_check
  end


  def chiku_checkbox(chiku_array, target_chiku)
    return chiku_array.index(target_chiku).nil? ? false : true
  end

  def set_gmap_hash(facilities)

    hash = Gmaps4rails.build_markers(facilities) do |facility, marker|
      marker.lat facility.y
      marker.lng facility.x
      marker.infowindow facility.shisetsu_name
      marker.json({title: facility.shisetsu_name})
    end

    logger.debug(hash)

    return hash

  end

end

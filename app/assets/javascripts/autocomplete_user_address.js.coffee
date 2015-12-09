$ ->
  $("#text_shisetsu_name").autocomplete
    source: (req, res) ->
      $.ajax
        url: "/facility/autocomplete_facility/" + encodeURIComponent(req.term) + ".json",
        dataType: "json",
        success: (data) ->
          res(data)
    ,
    autoFocus: true,
    delay: 300,
    minLength: 2
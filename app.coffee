google.load("visualization", "1", {packages:["corechart"]})
re = RegExp(/^\d+/mg)
last_data = null
last_width = null

configs = [
    { title: "0-100, by 10", range: 100, interval: 10 }
    { title: "0-100, by 5",  range: 100,  interval: 5 }
    { title: "0-100, by 25 [slots]",  buckets:[0,25,50,75,100] }
    { title: "0-10 [slots]",  buckets:[0..10] }
    { title: "0-5 [slots]",  buckets:[0..5] }
]

active_config = configs[0]


populate_select = (config_id, config_list)->
    select = $("#"+config_id)
    select.append("<option value=\"#{i}\">#{cfg.title}</option>") for cfg,i in config_list

calc = (force)->
    data = document.getElementById("data").value
    if !force and data == last_data and last_width == window.innerWidth
        return

    last_data = data
    last_width = window.innerWidth
    ratings_raw = data.match(re)
    if ratings_raw?
        ratings = _.map(ratings_raw, (v)->parseInt(v))
    else
        ratings = []

    graph(ratings)

stratify = (rankings)->
    if active_config.range?
        range = active_config.range
        interval = active_config.interval
        num_buckets = range / interval
        labels = ("#{x - (if x > interval then (interval-1) else interval)}-#{x}" for x in [interval..range] by interval)
    else
        num_buckets = active_config.buckets.length
        labels = ("#{x}" for x in active_config.buckets)

    values = Array.apply(null, new Array(num_buckets)).map(Number.prototype.valueOf,0)
    _.each rankings, (v)->
        if range?
            b = if v > 0 then Math.floor((v-1)/interval) else 0
        else
            b = v
        values[b] += 1

    merge = _.zip(labels, values)
    merge.unshift(["Ranking", "Count"])
    return merge

graph = (rankings)->
    merge = stratify(rankings, 100, 20)
    data = google.visualization.arrayToDataTable(merge)

    options =
          hAxis: {title: 'Rating'}
          vAxis: {title: 'Number of ratings'}
          legend: { position: "none" }

    chart = new google.visualization.ColumnChart(document.getElementById('graph'))
    chart.draw(data, options)

config_chg = ()->
    sel = document.getElementById("config_list")
    active_config = configs[sel.selectedIndex]
    calc(true)

populate_select("config_list", configs)
$("#config_list").change(config_chg)
setInterval(calc, 1000)

google.load("visualization", "1", {packages:["corechart"]})
re = RegExp(/^\d+/mg)
last_data = null
last_width = null

configs = [
    { title: "0-100, by 10", range: 100, interval: 10 }
    { title: "0-100, by 5",  range: 100,  interval: 5 }
    { title: "0-10",  buckets:[0..10] }
    { title: "0-5", buckets:[0..5] }
    { title: "0/25/50/100",  buckets:[0,25,50,75,100] }
    { title: "0/20/40/60/80/100",  buckets:[0,20,40,60,80,100] }
]

active_config = configs[0]

prepare_configs = (configs)->
    _.each configs, (cfg)->
        if cfg.buckets?
            cfg.continuous = (_.last(cfg.buckets) - _.first(cfg.buckets)) == cfg.buckets.length - 1
        if cfg.buckets and not cfg.continuous
            cfg.inv_buckets = []
            for v, i in cfg.buckets
                cfg.inv_buckets[v] = i

populate_select = (config_id, config_list)->
    select = $("#"+config_id)
    select.append("<option value=\"#{i}\">#{cfg.title}</option>") for cfg,i in config_list

parse_ratings = (text)->
    ratings_raw = text.match(re)
    if ratings_raw?
        ratings = _.map(ratings_raw, (v)->parseInt(v))
    else
        ratings = []

calc = (force)->
    data = document.getElementById("data").value
    if !force and data == last_data and last_width == window.innerWidth
        return

    last_data = data
    last_width = window.innerWidth

    ratings = parse_ratings(data)

    graph(ratings)

stratify = (rankings, active_config)->
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
        b = null
        if range?
            if 0 <= v <= range
                b = if v > 0 then Math.floor((v-1)/interval) else 0
        else
            if active_config.continuous
                if 0 <= v <= _.last(active_config.buckets)
                    b = v
            else
                b = active_config.inv_buckets[v]
        values[b] += 1 unless not b?

    _.zip(labels, values)

graph = (rankings)->
    merge = stratify(rankings, active_config)
    merge.unshift(["Ranking", "Count"])
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

prepare_configs(configs)
populate_select("config_list", configs)
$("#config_list").change(config_chg)

setInterval(calc, 1000) unless QUnit?  # Don't monitor if testing

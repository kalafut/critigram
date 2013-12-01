google.load("visualization", "1", {packages:["corechart"]})
re = RegExp(/^\d+/mg)
last_data = null
last_width = null

calc = ()->
    data = document.getElementById("data").value
    if data == last_data and last_width == window.innerWidth
        return

    last_data = data
    last_width = window.innerWidth
    ratings_raw = data.match(re)
    if ratings_raw?
        ratings = _.map(ratings_raw, (v)->parseInt(v))
    else
        ratings = []

    graph(ratings)

graph = (rankings)->
    labels = ("#{x - (if x > 10 then 9 else 10)}-#{x}" for x in [10..100] by 10)
    values = Array.apply(null, new Array(10)).map(Number.prototype.valueOf,0)
    _.each rankings, (v)->
        b = if v > 0 then Math.floor((v-1)/10) else 0
        values[b] += 1
    merge = _.zip(labels, values)
    merge.unshift(["Ranking", "Count"])
    data = google.visualization.arrayToDataTable(merge)

    options =
          hAxis: {title: 'Rating range'}
          vAxis: {title: 'Number of ratings'}
          legend: { position: "none" }

    chart = new google.visualization.ColumnChart(document.getElementById('graph'))
    chart.draw(data, options)

setInterval(calc, 1000)

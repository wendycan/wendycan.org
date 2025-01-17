tempApp = angular.module('tempApp',[])

tempApp.controller 'TempCtrl', ['$scope', '$http', ($scope, $http)->
  # functin and variable define
  url = "/data.json"
  config =
    method: "GET"
    url: url
    headers:
      "Authorization": "Bearer #{Temp.ReadToken}"
  $scope.points = []
  $scope.graph = {}
  interalId = {}
  $('#data-stop').css 'display', 'none'
  $(document).foundation ->
    tooltips:
      disable_for_touch: true
  $scope.heart_rate = '空'
  $scope.qrs_time = '空'

  $scope.filterDate = (clickevent)->
    start = $('#datetimestart').val()
    end = $('#datetimeend').val()
    $('#loader').show()
    clearInterval(interalId)
    $('#data-sync').css 'display', 'none'
    $('#data-stop').css 'display', 'inline-block'
    fetchTempData(new Date(start), new Date(end), 0, 130, ->
      $scope.graph.series[0].data = $scope.points
      $scope.graph.render()
      $('#loader').hide()
    )
  $scope.startSync = (clickevent)->
    $('#data-sync').css 'display', 'inline-block'
    $('#data-stop').css 'display', 'none'
    setRefresh()

  $scope.exportData = (clickevent)->
    data = []
    $scope.starttime = $('#datetimestart').val()
    $scope.endtime = $('#datetimeend').val()
    for point in $scope.points
      do(point)->
        tmp = {}
        tmp.t = moment(point.x * 1000).utc()
        tmp.v = point.y
        data.push tmp
    blob = new Blob([JSON.stringify(data)], {type: "text/plain;charset=utf-8"})
    saveAs(blob,"data.json")

  setRefresh = ->
    interalId = setInterval ->
      result = initTimePicker()
      i = Math.random()
      m = Math.floor(i * 50)
      fetchTempData(new Date(result.start), new Date(result.end), m, m + 130, =>
        $scope.graph.series[0].data = $scope.points
        $scope.graph.render()
        addAnalysis()
      )
    , 2000

  initGraph = ->
    if $scope.points.length > 0
      data = $scope.points
    else
      data = [{x:0, y:0}]
    $scope.graph = new Rickshaw.Graph {
      element: document.querySelector('#temp-graph'),
      renderer: 'line',
      interpolation: 'linear',
      series: [{
        color: "#ff0059",
        name: '心电',
        data: data
        }]
    }
    time = new Rickshaw.Fixtures.Time()
    seconds = time.unit('seconds')
    axes = new Rickshaw.Graph.Axis.Time( {
      timeUnit: seconds,
      graph: $scope.graph
     } )
    y_axis = new Rickshaw.Graph.Axis.Y( {
      graph: $scope.graph,
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
      ticksTreatment: 'glow'
    } )
    hoverDetail = new Rickshaw.Graph.HoverDetail( {
      graph: $scope.graph
    } )
    legend = new Rickshaw.Graph.Legend( {
      element: document.querySelector('#legend'),
      graph: $scope.graph
    } )
    $scope.graph.render()

  getAverage= (i, data)->
    sum = 0
    k = 0
    for j in [-1..1]
      do(j)=>
        if data[j+i]
          k++
          sum += data[j+i].y
    result = sum/k
    result

  getSlope = (i, j, data)->
    slop = (data[i].y - data[j].y)/(i - j)

  getLP = (i, data, max)->
    if (i <= 0 || i>= data.length)
      return -1
    for m in [i..1]
      slop = getSlope(m, m-1, data)
      if slop < 0
        break
    if (Math.abs(data[m+1].y - data[max].y) > 400 )
      return m+1
    else
      return getLP(m - 1, data, max)

  getRP = (i, data, max)->
    if (i <= 0 || i >= data.length)
      return -1
    for m in [i..(data.length-1)]
      slop = getSlope(m, m+1, data)
      if slop > 0
        break
    if (Math.abs(data[m-1].y - data[max].y) > 400 )
      return m-1
    else
      return getRP(m + 1, data, max)

  addAnalysis = ()->
    data = $scope.points
    max_avr = {
      index: -1,
      v: 0
    }
    for i in [0..data.length]
      do(i)=>
        avr = getAverage(i, data)
        if avr >= max_avr.v
          max_avr.index = i
          max_avr.v = avr
    max_avr_t = {
      index: -1,
      v: 0
    }
    for i in [0..data.length]
      do(i)=>
        if i != max_avr.index
          avr = getAverage(i, data)
          if avr >= max_avr_t.v
            max_avr_t.index = i
            max_avr_t.v = avr
    $scope.heart_rate = Math.round(60/((max_avr.index - max_avr_t.index) * 1/80))
    l_index = getLP(max_avr.index, data, max_avr.index)
    r_index = getRP(max_avr.index, data, max_avr.index)
    $scope.qrs_time = (r_index - l_index)/80 * 1000

  initTemp = =>
    result = initTimePicker()

    fetchTempData(new Date(result.start), new Date(result.end), 0, 130,  =>
      initGraph()
      addAnalysis()
      setRefresh()
    )

  initTimePicker = ->
    now = new Date()
    end = "#{now.getFullYear()}/#{now.getMonth() + 1}/#{now.getDate()} #{now.getHours()}:#{now.getMinutes()}:#{now.getSeconds()}"
    start = "#{now.getFullYear()}/#{now.getMonth() + 1}/#{now.getDate()} #{now.getHours()}:#{now.getMinutes()}:#{now.getSeconds() - 3}"
    $('#datetimestart').datetimepicker({
      lang: 'ch',
      value: start
      })
    $('#datetimeend').datetimepicker({
      lang: 'ch',
      value: end
      })
    $scope.starttime = $('#datetimestart').val()
    $scope.endtime = $('#datetimeend').val()
    {start: start,end: end}

  fetchTempData = (start, end, m, n, onSuccess = false)->
    endIso = end.toISOString()
    startIso = start.toISOString()
    config.params =
      start: startIso
      end: endIso
      order: 'asc'
    $http(config).success (data)->
      $scope.data = data
      $scope.points = []
      for i in [m..n]
        do(i)->
          point = $scope.data.datapoints[i]
          tmp = {}
          date = new Date(point.t)
          tmp.x = Date.parse(date)/1000
          tmp.y = point.v
          $scope.points.push tmp
      if !!onSuccess
        onSuccess()

  renderGraph = ()->
    $scope.graph.series[0].data = $scope.points
    $scope.graph.render()

  # function call
  initTemp()
]

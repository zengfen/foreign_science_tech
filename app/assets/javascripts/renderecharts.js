function renderEcharts(id, option) {
  var dom = document.getElementById(id)
    , instance = echarts.getInstanceByDom(dom);
    instance = echarts.init(dom);
    instance.setOption(option);
    return instance
}
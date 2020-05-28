;(function() {
  window.renderEchart = function renderEchart(el, options) {
    var $el = $(el);
    if(!$el.length) return;
    var instance = echarts.getInstanceByDom($el[0]);
    if(!instance) {
      $el.empty();
      instance = echarts.init($el[0]);
    }
    instance.setOption(options);
    return instance;
  };

  window.rand = function(min, max) {
    return Math.floor(Math.random() * (max - min) + min);
  };

  var resize_timer;

  $(window).on('resize', function() {
    resize_timer && clearTimeout(resize_timer);
    resize_timer = setTimeout(function() {
      $('[_echarts_instance_]').each(function(index, dom) {
        try {
          var instance = echarts.getInstanceByDom(dom);
          if(instance && instance.resize && !instance.isDisposed()) {
            instance.resize();
          }
        } catch(err) {}
      });
    }, 50);
  });
})();
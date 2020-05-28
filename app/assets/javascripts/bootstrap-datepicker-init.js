// bootstrap-datepicker
;(function($) {
  if(!$.fn.datepicker) {
    console.warn('bootstrap-datepicker is not loaded.');
    return false;
  }
  var today = new Date();
  var default_opts = {
    language: 'zh-CN',
    format: "yyyy-mm-dd",
    autoclose: true,
    todayHighlight: true,
    endDate: today,
    clearBtn: true,
    container: 'body'
  };

  function initDateRangePicker($wrap, opts) {
    opts = opts || {};
    $wrap.each(function() {
      var $inputs = $(this).find('.datepicker-input');
      var $start_date = $inputs.eq(0);
      var $end_date = $inputs.eq(1);

      initDatePicker($start_date, $end_date, opts);
    });
  }

  function initDatePicker($start_date, $end_date, opts) {
    var isSinglePicker = false;

    if(!$end_date) {
      opts = null;
      isSinglePicker = true;
    } else if(!($end_date instanceof jQuery)) {
      opts = $end_date;
      $end_date = null;
      isSinglePicker = true;
    }
    opts = $.extend(true, {}, default_opts, opts);

    $start_date.datepicker(opts).on('changeDate', function(e) {
      if(!isSinglePicker) {
        var start = $start_date.datepicker('getDate');
        var end = $end_date.datepicker('getDate');
  
        if(start && end && start > end) {
          $end_date.datepicker('setDate', start);
        }
      }
    });

    if(!isSinglePicker) {
      $end_date.datepicker(opts).on('changeDate', function(e) {
        var start = $start_date.datepicker('getDate');
        var end = $end_date.datepicker('getDate');
  
        if(start && end && start > end) {
          $start_date.datepicker('setDate', end);
        }
      });
    }
  }

  window.initDateRangePicker = initDateRangePicker;
  window.initDatePicker = initDatePicker;
})(jQuery);
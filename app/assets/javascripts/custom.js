// gConfirm
(function($) {
  function getConfirmModal() {
    var $modal = $('#modal_custom_confirm');
    
    if(!$modal.length) {
      $modal = $([
        '<div class="modal fade" id="modal_custom_confirm">',
          '<div class="modal-dialog">',
            '<div class="modal-content">',
              '<div class="modal-header">',
                '<a href="javascript: void(0)" class="close" data-dismiss="modal">&times;</a>',
                '<h4 class="modal-title"></h4>',
              '</div>',
              '<div class="modal-body">',
                '<div class="modal-confirm-message"></div>',
                '<div class="modal-btn-group text-right" style="margin-top: 10px">',
                  '<button class="btn btn-sm btn-white js-modal-btn__cancel" type="button"></button>',
                  '<button class="btn btn-sm btn-primary js-modal-btn__confirm" type="button" style="margin-left: 10px"></button>',
                '</div>',
              '</div>',
            '</div>',
          '</div>',
        '</div>'
      ].join(''));

      $(document.body).append($modal);
    }

    return $modal;
  }
  function gConfirm(opts) {
    opts = $.extend({
      title: '确认框',
      message: '&nbsp;',
      extraModalClass: '',
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      showCancelButton: true,
      showCloseButton: true,
      onConfirm: null, // function
      onCancel: null, // function
      onShow: null,
      onHide: null
    }, opts);

    var $modal = getConfirmModal();
    var $modal_title = $modal.find('.modal-title');
    var $btn_confirm = $modal.find('.js-modal-btn__confirm');
    var $btn_cancel = $modal.find('.js-modal-btn__cancel');
    var $btn_close = $modal.find('.modal-header').find('.close');
    var $message = $modal.find('.modal-confirm-message');

    $modal_title.html(opts.title);
    $btn_confirm.html(opts.confirmButtonText);
    $message.html(opts.message);

    if(opts.showCancelButton) {
      $btn_cancel.html(opts.cancelButtonText).show();
    } else {
      $btn_cancel.hide();
    }

    if(opts.showCloseButton) {
      $btn_close.show();
    } else {
      $btn_close.hide();
    }

    $btn_confirm.off('click').on('click', function() {
      $modal.modal('hide');
      opts.onConfirm && opts.onConfirm();
    });

    $btn_cancel.off('click').on('click', function() {
      $modal.modal('hide');
      opts.onCancel && opts.onCancel();
    });

    $modal.off('show.bs.modal').on('show.bs.modal', function() {
      opts.onShow && opts.onShow();
    });

    $modal.off('hidden.bs.modal').on('hidden.bs.modal', function() {
      opts.onHide && opts.onHide();
    });

    $modal.modal({backdrop: 'static', keybaord: false});
  }

  window.gConfirm = gConfirm;
})(jQuery);

// datepicker
(function($) {
  $.fn.datepicker.dates['zh-cn'] = {
    days: ["周日", "周一", "周二", "周三", "周四", "周五", "周六", "周日"],
    daysShort: ["日", "一", "二", "三", "四", "五", "六", "七"],
    daysMin: ["日", "一", "二", "三", "四", "五", "六", "七"],
    months: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
    monthsShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
    today: "今天",
    titleFormat: 'yyyy年 MM',
    clear: "清除"
  };

  var today = new Date();
  var default_opts = {
    language: 'zh-cn',
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
  
        if(end && start > end) {
          $end_date.datepicker('setDate', start);
        }
      }
    });

    if(!isSinglePicker) {
      $end_date.datepicker(opts).on('changeDate', function(e) {
        var start = $start_date.datepicker('getDate');
        var end = $end_date.datepicker('getDate');
  
        if(start && start > end) {
          $start_date.datepicker('setDate', end);
        }
      });
    }
  }

  window.initDateRangePicker = initDateRangePicker;
  window.initDatePicker = initDatePicker;
})(jQuery);
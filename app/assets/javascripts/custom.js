// gConfirm
(function($) {
  function getConfirmModal() {
    var $modal = $('#modal_custom_confirm');
    
    if(!$modal.length) {
      $modal = $([
        '<div class="modal fade" id="modal_custom_confirm">',
          '<div class="modal-dialog" style="width: 450px;margin-top: 20vh">',
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

    $modal.modal();
  }

  window.gConfirm = gConfirm;
})(jQuery);
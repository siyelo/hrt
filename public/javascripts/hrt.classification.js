var HrtClassification = {};

var ALLOWED_VARIANCE = 0.05;

HrtClassification.init = function () {
  // collapsible checkboxes for tab1
  var mode = document.location.search.split("=")[1]
  if (mode != 'locations') {
    var tab = 'tab1';
    $('.' + tab + ' ul.activity_tree').collapsibleCheckboxTree({tab: tab});
    $('.' + tab + ' ul.activity_tree').validateClassificationTree();
  }

  HrtClassification.checkRootNodes('budget');
  HrtClassification.checkRootNodes('spend');
  HrtClassification.checkAllChildren();
  HrtClassification.showSubtotalIcons();

  $('.js_upload_btn').click(function (e) {
    e.preventDefault();
    $(this).parents('.upload').find('.upload_box').toggle();
  });

  $('.js_submit_btn').click(function (e) {
    var ajaxLoader = $(this).closest('ol').find('.ajax-loader');
    ajaxLoader.show();
    HrtClassification.checkRootNodes('spend');
    HrtClassification.checkRootNodes('budget');
    if ($('.invalid_node').size() > 0){
      e.preventDefault();
      alert('The classification tree could not be saved.  Please correct all errors and try again')
      ajaxLoader.hide();
    };
  });


  $('#js_budget_to_spend').click(function (e) {
    e.preventDefault();
    if ($(this).find('img').hasClass('approved')) {
      alert('Classifications for an approved activity cannot be changed');
    } else if (confirm('This will overwrite all Past Expenditure percentages with the Current Budget percentages. Are you sure?')) {
      $('.js_budget input').each(function () {
        var element = $(this);
        element.parents('.js_values').find('.js_spend input').val(element.val());
      });
      HrtClassification.checkRootNodes('spend');
      HrtClassification.checkAllChildren();
    };
  });

  $('#js_spend_to_budget').click(function (e) {
    e.preventDefault();
    if ($(this).find('img').hasClass('approved')) {
      alert('Classifications for an approved activity cannot be changed');
    } else if (confirm('This will overwrite all Current Budget percentages with the Past Expenditure percentages. Are you sure?')) {
      $('.js_spend input').each(function () {
        var element = $(this);
        element.parents('.js_values').find('.js_budget input').val(element.val());
      });
      HrtClassification.checkRootNodes('budget');
      HrtClassification.checkAllChildren();
    };
  });

  $(".percentage_box").keyup(function(event) {
    var element = $(this);
    var isSpend = element.parents('div:first').hasClass('spend')
    var type = (isSpend) ? 'spend' : 'budget';
    var childLi = element.parents('li:first').children('ul:first').children('li');

    HrtClassification.updateSubTotal(element);
    Hrt.updateTotalValue(element);

    if (element.val().length == 0 && childLi.size() > 0) {
      HrtClassification.clearChildNodes(element, event, type);
    }

    var period = 190;
    var bksp = 46;
    var del = 8;
    //update parent nodes if: numeric keys, backspace/delete, period or undefined (i.e. called from another function)
    if (typeof event.keyCode == 'undefined' || (event.keyCode >= 48 && event.keyCode <= 57 ) || event.keyCode == period || event.keyCode == del || event.keyCode == bksp || event.keyCode >= 37 && event.keyCode <= 40){
      HrtClassification.updateParentNodes(element, type)
    }
    //check whether children (1 level deep) are equal to my total
    if (childLi.size() > 0){
      HrtClassification.compareChildrenToParent(element, type);
    };

    //check whether root nodes are = 100%
    HrtClassification.checkRootNodes(type);

  });

  HrtForm.numericInputField(".percentage_box, .js_spend, .js_budget");
};


HrtClassification.updateParentNodes = function (element, type) {
  type = '.' + type + ':first'
  var parentElement = element.parents('ul:first').prev('div:first').find(type).find('input');
  var siblingLi = element.parents('ul:first').children('li');

  var siblingValue = 0;
  var siblingTotal = 0;
  siblingLi.each(function (){
    siblingValue = parseFloat($(this).find(type).find('input:first').val());
    if ( !isNaN(siblingValue) ) {
      siblingTotal = siblingTotal + siblingValue;
    }; 
  });
  if ( siblingTotal !== 0 ) {
    parentElement.val(siblingTotal);
    parentElement.trigger('keyup');
  }
};

HrtClassification.clearChildNodes = function (element, event, type) {
  var bksp = 46;
  var del = 8;
  type = '.' + type + ':first'

  if ( (event.keyCode == bksp || event.keyCode == del) ){
    childNodes = element.parents('li:first').children('ul:first').find('li').find(type).find('input');

    var childTotal = 0;
    childNodes.each(function (){
      childValue = parseFloat($(this).val())
      if (!isNaN(childValue)) {
        childTotal = childTotal + childValue
      };
    });

    if ( childTotal > 0 && confirm('Would you like to clear the value of all child nodes?') ){
      childNodes.each(function(){
        if ( $(this).val !== '' ){
          $(this).val(' ');
          HrtClassification.updateSubTotal($(this));
        }
      });
    }
  }
};

HrtClassification.updateSubTotal = function (element) {
  var activity_budget = parseFloat(element.parents('ul:last').attr('activity_budget'));
  var activity_spend = parseFloat(element.parents('ul:last').attr('activity_spend'));
  var activity_currency = element.parents('ul:last').attr('activity_currency');
  var elementValue = parseFloat(element.val());
  var subtotal = element.siblings('.subtotal_icon');
  var isSpend = element.parents('div:first').hasClass('spend')

  if ( elementValue > 0 ){
    subtotal.removeClass('hidden')
    subtotal.attr('title', (isSpend ? activity_spend : activity_budget * (elementValue/100)).toFixed(2) + ' ' + activity_currency);
  } else {
    subtotal.attr('title','');
    subtotal.addClass('hidden');
  }
};

HrtClassification.checkAllChildren = function(){
  var inputs = $('.percentage_box')
  inputs.each(function(){
    if ( $(this).val !== '' ){
      var type = $(this).hasClass('js_spend') ? 'spend' : 'budget'
      HrtClassification.compareChildrenToParent($(this), type);
    }
  });
}

HrtClassification.compareChildrenToParent = function(parentElement, type){
  var childValue = 0;
  var childTotal = 0;
  var childLi = parentElement.parents('li:first').children('ul:first').children('li');
  type = '.' + type + ':first'

  childLi.each(function (){
    childValue = parseFloat($(this).find(type).find('input:first').val())
    if (!isNaN(childValue)) {
      childTotal = childTotal + childValue
    };
  });

  var parentValue = parseFloat(parentElement.val()).toFixed(2)
  childTotal = childTotal.toFixed(2)

  if ( (Math.abs(childTotal - parentValue) > ALLOWED_VARIANCE) && childTotal > 0){
    parentElement.addClass('invalid_node tooltip')
    var message = "This amount is not the same as the sum of the amounts underneath (" ;
    message += parentValue + "% - " + childTotal + "% = " + (parentValue - childTotal) + "%)";
    parentElement.attr('original-title', message) ;
  } else {
    parentElement.removeClass('invalid_node tooltip')
  };
};

HrtClassification.checkRootNodes = function(type){
  var topNodes =  $('.activity_tree').find('li:first').siblings().andSelf();
  var total = 0;
  var value = 0;
  type = '.' + type + ':first'

  topNodes.each(function(){
    value = $(this).find(type).find('input').val();
    if (!isNaN(parseFloat(value))){
      total += parseFloat($(this).find(type).find('input').val());
    };
  });

  $('.totals').find(type).find('.amount').html(total);

  if ( (Math.abs(total - 100.00) > ALLOWED_VARIANCE) && total > 0){
    topNodes.each(function(){
      rootNode = $(this).find(type).find('input');
      if (rootNode.val().length > 0 && (!(rootNode.hasClass('invalid_node tooltip')))){
        rootNode.addClass('invalid_node tooltip');
      }
      var message = "The root nodes do not add up to 100%";
      rootNode.attr('original-title', message) ;
    });
  } else {
    topNodes.each(function(){
      rootNode = $(this).find(type).find('input');
      if (rootNode.attr('original-title') != undefined && rootNode.attr('original-title') == "The root nodes do not add up to 100%"){
        rootNode.removeClass('invalid_node tooltip');
        rootNode.attr('original-title', '')
      }
    });

  };
};

HrtClassification.showSubtotalIcons = function(){
  $('.tab1').find('.percentage_box').each(function(){
    if ($(this).val().length > 0) {
      $(this).siblings('.subtotal_icon').removeClass('hidden')
    }
  });
};

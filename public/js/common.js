
	jQuery(function($){
		$("a[rel='delete']").restnoodel({ask: true});
		$("a[rel='delete-now']").restnoodel({ask: false});
	});

	// Inline editing (beta)
	var _call=null;$.fn.blockwrapper=function(){$(this).each(function(){o='<div class="save editor-btn-save"></div>"';$(this).prepend($(o));var ef=$(this).children('.editor, .front');var ec=$(this).find('.editor-content');var fc=$(this).find('.front-content');var wrapper=$(this);var val=$.trim(fc.html());ec.attr('value',val);$(this).change(function(){if(ec.attr('value')!=val){}else{}});ec.css('width','100%');fc.hide();$(this).find('textarea').autoResize({onResize:function(){},animate:false,animateCallback:function(){},extraSpace:4}).css('height',fc.height()+4+'px');$(this).find('.save').click(function(){if(null!=_call)return;form=$(this).parent().parent().find('.content-form');dataString='uri='+form.find('input[name=uri]').val()+'&key='+form.find('input[name=key]').val()+'&content='+form.find('textarea[name=content]').val()+'&_method=PUT';if(0==$('#overlay').length){$('body').append('<div id="overlay"></div>')}else{$('#overlay').show()}var err=setTimeout(function(){error()},10000);_call=$.ajax({method:'POST',url:form.attr('action'),data:dataString,success:function(m){clearTimeout(err);wrapper.parent().html(m);$('#overlay').hide();_call=null},error:function(){error()}});function error(){if(null!=_call){_call.abort();_call=null}$('#overlay').hide();displayError(['Error, couldn\'t save node content.'])}})});return this};
		
	// Message/Error stack		
	function dsplStack(msg,s){
		var n=s+'_stack';
		str = '<ul>';
		for (var key in msg) str += '<li>' + msg[key] + '</li>';
		str += '</ul>';
		$('#'+n).html(str).show();
		setTimeout(function(){ $('#'+n).fadeOut(); }, 3000);
	}

	function displayMessage(msg){dsplStack(msg, 'message');}
	function displayError(msg){dsplStack(msg, 'error');}
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<style>
body{  
	width : 100% !important;
	height : 100% !important;
	overflow-x:hidden;
}
</style>

<div id="nav_btn_grp" class="text-center nav_btn" style="height:100%;">
	<div class="" style="background: #ffffff;margin:0px;border:0px;">
		<h3 class="col-xs-12 col-sm-6 text-left text-left-sm" style="padding:10px 0px 30px 20px;margin:0;text-align:center;"><i class="glyphicon glyphicon-download-alt"></i>&nbsp;&nbsp;&nbsp; <span id="menuName"></span>
			<br> [ <spring:message code="다운로드"/> ] <span class="down_time"></span>
		</h3>
	</div>
	<div class="note note-info" style="height:100%;background: #ffffff;margin-bottom:0px;">
		<!--<img src="/images/progressbar_green.gif" style="margin-bottom: 10px;height:20px;width:400px;">-->
		<img src="/resources/images/progressbar_blue.gif" style="margin-bottom: 10px;height:30px;width:400px;">
		<h5 style="color: #0a0a0a"><spring:message code="다운로드_시간은_데이터_크기에_따라_5-30분_정도_소요됩니다"/></h5>
	</div>

</div>

<script type="text/javascript">
$(document).ready(function()
{
	var export_type = '${export_type}';
	var extract,menuName,wurl;
	var params = "";
	var result = getQueryString();
	console.log(result);
	for (var key in result) {
		if(key == 'extract'){
			extract = result[key];
		}else if(key == 'export_type'){
			export_type = result[key];
		}else if(key == 'menuName'){
			menuName = decodeURI(result[key]);
		}else if(key == 'wurl'){
			wurl = result[key].split("#")[0];
		}else{
			if(params==""){
				params += key+'='+result[key];
			}else{
				params += "&"+key+'='+result[key];
			}
		}
	  	console.log( key + ": " + result[key] );
	}
	$("#menuName").text(menuName);
	console.log(params);
	
	var url = "";
	if(export_type=='excel'){
		//setDataLoding('start', 'excel' , extract);
		url = "/excel/download";
	}else{
		//setDataLoding('start', 'pdf' , extract);
		url = "/pdf/download";
	}

	downloadData(export_type, url,extract,wurl,params, menuName);
});
function getQueryString()
{
    var queryString= [];
    var hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        queryString[hash[0]] = hash[1];
    }
    return queryString;
}

//데이터 다운로드_Excel
var downloadData = function(type, url, extract,wurl,params,menuName) 
{

	//파라미터 세팅
	var tableau_viz 	= opener.tableauViz;
	var actionSheet 	= tableau_viz.getWorkbook().getActiveSheet().getUrl();
		actionSheet 	= actionSheet.split('#')[0];
	var sheets          = tableau_viz.getWorkbook().getPublishedSheetsInfo();
	var sheetInfo = "";
	for(var i=0;i<sheets.length;i++){
		sheetInfo += sheets[i].getUrl().split('#')[0]+"||";
	} 
	
	$.ajax({type : "POST",
		url: url,
		cache: false,
		isIndicatorShowing : false,
		data: {
			extractOption : extract,
			exportUrl 	: wurl,
			params 		: params,
			sheets 		: sheets,
			actionSheet	: actionSheet,
			sheets		: sheetInfo,
			viewName	: menuName
		},
		success: function(response)
		{

			var fileType= '';
			if(type=='excel'){
				fileType= '.xlsx';
			}else{
				fileType= '.pdf';
			}
			
			if (response.resultCode == -2) {
				console.log(response.resultCode);
			} else {
				var fileName = response.resultMessage;
				
				if(fileName.length>0){
					//setDataLoding('end', type , extract);
					var downFrame 	= $('#downForm',opener.document);

					var $form = $('<form id="downForm"></form>');
				    $form.attr('action', '/'+type+'/downloadFile');
				    $form.attr('method', 'post');
					
					var fileNameHtml = $('<input type="hidden" name="fileName" id="downFileName" value="'+fileName+'">');
				    var aliasNameHtml = $('<input type="hidden" name="aliasName" id="downAliasName" value="'+menuName+fileType+'">');
				    var csrf = $('<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>');
					
				    
				    $form.append(fileNameHtml);
				    $form.append(aliasNameHtml);
				    $form.append(csrf);

				    //$(opener.document).find(".px-content").append($form[0].outerHTML);
				    //$('#downForm',opener.document).submit();
				
				    opener.location.assign('/' + type + '/downloadFile' + '?fileName=' + encodeURIComponent(fileName) + "&aliasName=" + encodeURIComponent(menuName+fileType));
					opener.bootbox.alert('<spring:message code="다운로드가_완료되었습니다"/>');
					//$('#downForm',opener.document).remove();
					
					window.close();
				}
			}
		},
		error: function(a, b, c) {
			console.log(a, b, c);
		}
	});
	//this.vizList[this.vizList.length-1].showExportCrossTabDialog()

};


var interval_down_time;
var passMin, passSec;
function setDataLoding(type, gubun , extract){
	var targetID = '';
	if(gubun == 'excel'){
		if(extract==2){ 	 	targetID = 'down_excel_workbook';
		}else if(extract==1){ 	targetID = 'down_excel_sheet';
		}
	}else if(gubun == 'pdf'){
		if(extract==1){ 		targetID = 'down_pdf_workbook';
		}else if(extract==2){ 	targetID = 'down_pdf_sheet';
		}
	}
	if(type=='start'){
		$('#'+targetID + ' > a > span',opener.document).html('<img src="/resources/images/loading_down.gif" style="margin-right:5px;height:15px;width:15px;" />'+$('#'+targetID+' > a > span',opener.document).text());//PDF 현재페이지 다운
		$('#'+targetID ,opener.document).css('cursor','default');
		//$('#'+targetID ,opener.document).attr('onclick','');
		//$('#'+targetID ,opener.document).unbind('click');
		$('#'+targetID + '>a',opener.document).attr('disabled', true );
		$('#'+targetID +'>a',opener.document).attr('readonly', true);

		passMin = 0;
		passSec = 0;
		interval_down_time = setInterval(function(){
			passSec++;
			if(60<=passSec){passMin++, passSec=0; }
			$('.down_time').css('color','#000000');
			$('.down_time').text(set00(passMin)+":"+set00(passSec));
		},1000);

	}else if(type =='end'){

		if(interval_down_time){
			passMin = 0;
			passSec = 0;
			clearInterval(interval_down_time);
		}

		$('#'+targetID+' > a > span > img',opener.document).remove();
		$('#'+targetID,opener.document).css('cursor','pointer');
		$('#'+targetID+ '>a' ,opener.document).removeAttr('disabled');
		$('#'+targetID+'>a' ,opener.document).attr('readonly',false);
	}
}
function set00(number){
	var strNumber = "00"+number;
	return strNumber.substring(strNumber.length-2,strNumber.length);
}

</script>
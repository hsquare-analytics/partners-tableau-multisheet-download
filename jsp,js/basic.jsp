<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<link rel="stylesheet" href="${resourcesPath}/css/jquery-comments.css" />

<script src="${resourcesPath }/js/tableau.js?u=v2"></script>
<script src="${resourcesPath}/javascripts/jquery-comments.js"></script>
<script src="${resourcesPath}/js/texceldown.js"></script>

<style type="text/css">
	html {
		overflow-x: auto;
	}
	
	body {
		min-height: 100%;
		position: relative;
	}
	
	.px-footer {
		position: absolute;
		bottom: 0;
		left: 0;
		right: 0;
	}
	
	#cachingImageWrapper {
		/* float: left; */
		width: 100%;
		text-align: center;
	}
	
	#cachingImage {
		border: 1px solid rgb(226, 226, 226);
	}
	
	.viz-chart {
		border: 0px;
		overflow: visible !important;
		text-align: left;
		overflow: auto;
		width: 100%;
		height: 100%;
	}
	
	.viz-chart iframe {
		margin: 0 auto;
	}
	
	#div_param {
		height: 42px;
		position: absolute;
		z-index: 100;
		margin-top: 35px;
		margin-left: 2px;
		background-color: #fff;
		display: none;
	}
	
	#div_param select {
		padding-top: 0;
		padding-bottom: 0;
		line-height: 29px;
		height: 20px;
		font-size: 11px;
		padding-left: 3px;
		padding-right: 3px;
	}
	
	#frequency {
		float: left;
		margin-right: 50px;
		width: 100%;
		margin-bottom: 10px;
	}
	
	#detailTime {
		width: 100%;
	}
	
	.weekly {
		float: left;
		margin-right: 10px;
	}
	
	.weekly-checkbox-group {
		float: left;
		margin-right: 20px;
	}
	
	.time-weekly {
		float: right;
	}
	
	.monthly-day {
		margin-bottom: 10px;
	}
	
	.time>input {
		width: 63px;
	}
	
	textarea {
		resize: vertical;
	}
	
	.target-box {
		min-width: 100px;
		margin-right: 5px;
		margin-top: 5px;
		border: 1px solid #bcbcbc;
		background-color: #dedede;
	}
	
	.target-box-name {
		padding: 3px 5px;
		float: left;
	}
	
	.target-box-remove {
		padding: 3px 5px;
		float: right;
		cursor: pointer;
		background-color: #c7c7c7;
	}
	
	select {
		height: 30px;
	}
	
	img-hover {
		opacity: 0.4;
		transition: opacity;
		-o-transition: opacity;
		-moz-transition: opacity;
		-webkit-transition: opacity;
		-khtml-transition: opacity;
	}
	
	.report-section {
		/* float: left;
		border: 1px solid #e2e2e2;
		background-color: #fff; */
	}
	
	.comment-section {
		height: 100%;
		width: 100%;
		padding-right: 5px;
	}
	
	.comment-panel {
		width: 100%;
		height: 100%;
		margin: 0 0 0 5px;
		padding: 20px;
	}
	
	#autoRefreshSection {
		margin-right: 5px;
	}
	
	:-ms-fullscreen {
		width: 100% !important;
		height: 100% !important;
	}
	
	.page-breadcrumb {
		height: 44px;
		padding: 10px 0px 10px 20px;
		margin: -20px -20px 15px;
	}
	
	#menu_nav li {
		margin-top: 2px;
	}
	
	#subscriptionModal .modal-body .input-table>tbody>tr>th {
		width: 160px;
	}
	
	.button-section .btn {
		padding: 5px 10px;
	}
	
	#subscriptionTarget {
		display: flex;
		flex-direction: row;
		flex-wrap: wrap;
	}
	
	.viz-chart-hidden {
		width: 1px !important;
		height: 1px !important;
	}
	
	.px-content {
		/* background-color: #fff; */
	}
</style>

<div class="px-content">
	<div id="div_param">
		<div style="float: left; padding-left: 10px; display: none;"><spring:message code="??????" /><select class="form-control combo_teableau" id="param-date0" style="width: 68px;"></select></div>
		<div style="float: left; padding-left: 10px; display: none;"><spring:message code="??????" /><select class="form-control combo_teableau" id="param-date1" style="width: 78px;"></select></div>
		<div style="float: left; padding-left: 10px; display: none;"><spring:message code="??????" /><select class="form-control combo_teableau" id="param-date2" style="width: 93px;"></select></div>
	</div>
	<ul id="menu_nav" class="breadcrumb page-breadcrumb">
		<li class="menu_nav_step1" style="display: none;"><a href="#" id="menu_nav_step1"></a></li>
		<li class="menu_nav_step2" style="display: none;"><a href="#" id="menu_nav_step2"></a></li>
		<li class="menu_nav_step3" style="display: none;"><a href="#" id="menu_nav_step3"></a></li>
		<li class="menu_nav_step4" style="display: none;"><a href="#" id="menu_nav_step4"></a></li>
		
		<div class="button-section" style="float:right;">
			<c:if test="${configParameter.basicSettingsVo.auto_refresh_use_yn eq 'Y' }">
			<!-- ?????? ?????? ?????? -->
				<button id="autoRefreshSection" type="button" class="btn btn-dark hidden btn-in-dashboard" onclick="onClickAutoRefresh()">
					<span class="btn-label-icon btn-dark-label-icon left fa fa-pause"></span>
				</button>
			</c:if>
			<!-- ?????? ?????? ?????? -->
			<div class="btn-group util-btn-group hidden">
			
				<c:if test="${'Y' eq currentMenu.infoBtnShowYn}">
				<!-- Info area......... -->
					<button id="btnFullScreen" type="button" class="btn btn-dark btn-in-dashboard" onclick="viewInfo()" title='Definition for this page'>
						<span class="glyphicon glyphicon-info-sign"></span>
					</button>
				</c:if>
				
				<c:if test="${!userVo.deviceIsMobile and configParameter.basicSettingsVo.full_screen_use_yn eq 'Y'}">
				<!-- ???????????? -->
				<button id="btnFullScreen" type="button" class="btn btn-dark btn-in-dashboard" onclick="showFullScreen()" title='Full screen'>
					<span class="glyphicon glyphicon-fullscreen"></span>
				</button>
				</c:if>
				
				<c:if test="${configParameter.basicSettingsVo.adhoc_use_yn eq 'Y' and showAdhocBtn eq 'Y'}">
				<!-- ad-hoc  -->
					<button id="btnAdHoc" type="button" class="btn btn-dark btn-in-dashboard" onclick="openAdhocWorkbook()" title='<spring:message code="AD-HOC"/>'>
						<span class="glyphicon glyphicon-wrench"></span>
					</button>
				</c:if>
				
				<c:if test="${configParameter.basicSettingsVo.subscription_use_yn eq 'Y' and configParameter.basicSettingsVo.email_use_yn eq 'Y'}">
				<!-- ?????? -->
					<button id="btnSubscription" type="button" disabled="true" class="btn btn-dark btn-in-dashboard" onclick="showSubscription()" title='<spring:message code="??????"/>'>
						<span class="glyphicon glyphicon-envelope"></span>
					</button>
				</c:if>
				
				<c:if test="${configParameter.basicSettingsVo.comment_use_yn eq 'Y'}">
				<!-- ?????? -->
					<button type="button" class="btn btn-dark btn-in-dashboard" data-toggle="sidebar" data-target="#comment-sidebar" title='<spring:message code="??????"/>'>
						<span class="glyphicon glyphicon-comment"></span>
					</button>
				</c:if>
				
				<c:if test="${configParameter.basicSettingsVo.excel_download_use_yn eq 'Y'}">
				<!-- ???????????? -->
					<div class="btn-group">
						<button type="button" class="btn dropdown-toggle dataExportBtn btn-dark btn-in-dashboard" data-toggle="dropdown" title='<spring:message code="????????????"/>'>
							<span class="glyphicon glyphicon-download-alt"></span>
						</button>
	
						<ul class="dropdown-menu dataExportDropDown pull-right">
							<!-- 
							<li id="down_excel_test"><a href="javascript: void(0)" onclick="excelDownReadSheet()">downexcel test</a></li>
							 -->
							<li id="down_excel_workbook"><a href="javascript: void(0)" onclick="openExcelDataPopup('2')"><span><spring:message code="??????_??????_????????????" /></span></a></li>
							<li id="down_excel_sheet"><a href="javascript: void(0)" onclick="openExcelDataPopup('1')"><span><spring:message code="??????_??????_????????????" /></span></a></li>
							<li id="down_pdf_workbook"><a href="javascript: void(0)" onclick="openPdfDataPopup('2')"><span><spring:message code="PDF_?????????_??????" /></span></a></li>
							<li id="down_pdf_sheet"><a href="javascript: void(0)" onclick="openPdfDataPopup('1')"><span><spring:message code="PDF_????????????_??????" /></span></a></li>
						</ul>
					</div>
				</c:if>
			</div>
		</div>
	</ul>

	<div id="cachingImageWrapper" class="report-section">
		<c:if test="${'Y' eq configParameter.basicSettingsVo.image_cache_use_yn }">
			<a style="cursor: default;">
				<c:url value="/image/cache/viewimage" var="cachingImageUrl">
					<c:choose>
						<c:when test="${userVo.deviceIsMobile }">
							<c:param name="imageName" value="${currentMenu.m_cachingImageName }" />
						</c:when>
						<c:otherwise>
							<c:param name="imageName" value="${currentMenu.cachingImageName }" />
						</c:otherwise>
					</c:choose>
				</c:url>
				<img id="cachingImage" src="${cachingImageUrl }" />
			</a>
		</c:if> 
	</div>

	<div id="reports-wrapper">
		<c:if test="${'Y' eq configParameter.basicSettingsVo.image_cache_use_yn }">
			<div id="reports" class="report-section" style="width: 1px; height: 1px;"></div>
		</c:if>
		
		<c:if test="${'Y' ne configParameter.basicSettingsVo.image_cache_use_yn }">
			<div id="reports" class="report-section" style="width: 100%; height: 100%;"></div>
		</c:if>
	</div>
</div>

<!-- comment -->
<div class="px-sidebar-right b-a-1" id="comment-sidebar">
	<a href="#" id="subscription-sidebar-toggle" class="bg-white darker border-panel text-default b-a-1" data-toggle="sidebar" data-target="#comment-sidebar"> <i class="fa fa-close"></i></a>
	<div id="commentSection" class="px-sidebar-content bg-white darken comment-section">
		<div class="panel comment-panel"></div>
	</div>
</div>

<!-- modal -->
<div id="subscriptionModal" class="modal in">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<span id="modalTitle"><spring:message code="??????" /></span>
			</div>

			<div class="modal-body">
				<form>
					<table class="input-table">
						<tr <c:if test="${userVo.adminYn ne 'Y' }"> class="hidden"</c:if>>
							<th scope="row"><label class="required"><spring:message code="??????_??????" /></label></th>
							<td>
								<input list="userList" name="subscriptionTarget" class="form-control">
								<datalist id="userList">
									<c:forEach items="${userList }" var="user" varStatus="i">
										<option data-value="${user.seq }" value="${user.name }(${user.id})"></option>
									</c:forEach>
								</datalist>
								<div id="subscriptionTarget"></div>
							</td>
						</tr>
						<tr>
							<th scope="row"><label class="required"><spring:message code="??????" /></label></th>
							<td>
								<input type="text" class="form-control" name="title" id="subscriptionTitle"/>
							</td>
						</tr>
						<tr>
							<th scope="row"><spring:message code="??????_??????(????????????)" /></th>
							<td>
								<textarea class="form-control" name="content" id="subscriptionContent"></textarea>
							</td>
						</tr>
						<tr>
							<th scope="row"><spring:message code="?????????_??????_??????" /></th>
							<td>
								<select class="form-control" name="subscriptionSchedule" id="subscriptionSchedule">
								</select>
							</td>
						</tr>
					</table>
				</form>
			</div>
			
			<div class="modal-footer">
				<div class="text-center">
					<button onclick="saveSubscription()" type="button" class="btn btn-md btn-in-grid-3">
						<spring:message code="??????"/>
					</button>
					<button type="button" class="btn btn-md btn-basic" data-dismiss="modal">
						<spring:message code="??????"/>
					</button>
				</div>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">

	var yearyn = "${currentMenu.yearYn}";
	var monthyn = "${currentMenu.monthYn}";
	var dayyn = "${currentMenu.dayYn}";
	var tabyn = "${currentMenu.tabYn}";
	var todayyn = "${currentMenu.todayYn}";
	var toolbarYn = "${currentMenu.toolbarYn}";
	var params ='{}';

	//var parameterList = JSON.parse('${parameterList}');
	var pdfPopupDown;
	var excelPopupDown;
	var frequency = JSON.parse('${scheduleFrequencyJson}');
	var detailTimeIdList = [ 'hourly', 'daily', 'weekly', 'monthly' ];
	var subscriptionTargetList = [];
	var currentMenuId = "${currentMenu.id}";
	var mySubscriptionList = JSON.parse('${mySubscriptionList}');
	
	var autoSwitchingYn;
	var autoSwitchingInterval;
	
	// ????????????(???/?????????)??? ?????? ?????? ??????
	/* user-header.jsp?????? ??????
	var useMobile = false;
	var isDeviceType = "desktop";
	useMobile = (deviceIsMobile === 'true'); //deviceIsMobile : ??????????????? ????????? ?????? ???????????????(SecurityUserVo??? ??????)

	//(????????? ??????) ???????????? ?????? ?????? ????????? ?????????('N')??? ??????, WEB??? ????????? ?????????
	if (setting_usermenu_mobileuse == 'N') {
		useMobile = false;
	}
	 */
	

	if (deviceIsMobile==='true') {
		//?????? ?????? ?????? ??????
		$('.button-section').hide();
		//main content ?????? ??????
		$('.px-content').css('padding', '0px 0px 0px 0px');
		$('#main-content').css('padding', '0px 0px 0px 0px');
		
		//?????? ??????
		$('#menu_nav').hide();
		
// 		$('#main-content').css('overflow-x', 'auto');
		//$('#div_param').css('width','100%');
		$('#div_param').css('height', '50px');
	}

	if (useMobile) {
		//???????????? ?????? ??????
		yearyn = "${currentMenu.m_yearYn}";
		monthyn = "${currentMenu.m_monthYn}";
		dayyn = "${currentMenu.m_dayYn}";
		tabyn = "${currentMenu.m_tabYn}";
		todayyn = "${currentMenu.m_todayYn}";
		//dataExportYn = "${currentMenu.m_dataExportYn}";
		
		/* user-header.jsp?????? ??????
		isDeviceType = 'phone';
		// ????????????(???/?????????)??? ?????? ?????? ??????
		if(_widthWin>=768){
			isDeviceType = 'tablet';
		}
		*/
	}
	
	autoSwitchingYn = !useMobile ? "${currentMenu.autoSwitchingYn}" : "${currentMenu.m_autoSwitchingYn}";
	autoSwitchingInterval = !useMobile ? "${currentMenu.autoSwitchingInterval}" : "${currentMenu.m_autoSwitchingInterval}";
	
	if("Y" === autoSwitchingYn && autoSwitchingInterval > 0) {
		autoSwitchingInterval *= 1000;
	} else {
		autoSwithingInterval = 5000;
	}
	
	var ishideTabs = tabyn != 'Y';

	if (yearyn == 'Y') {
		$('#param-date0').closest('div').css('display', '');
	}
	if (monthyn == 'Y') {
		$('#param-date1').closest('div').css('display', '');
	}
	if (dayyn == 'Y') {
		$('#param-date2').closest('div').css('display', '');
	}


	var pipTableau = {};
	var reportUrlList = new Array();
	
	if(isDeviceType=='desktop' || isDeviceType=='tablet'){
		params = ${currentMenu.paramsJson != '' && currentMenu.paramsJson != null ? currentMenu.paramsJson : '{}'};
		<c:forEach items="${reportDesktopUrlList}" var="item" varStatus="status">
			reportUrlList.push("<c:out value="${item}" escapeXml="false" />");
		</c:forEach>
	}else{
		params = ${currentMenu.m_paramsJson != '' && currentMenu.m_paramsJson != null ? currentMenu.m_paramsJson : '{}'};
		<c:forEach items="${reportMobileUrlList}" var="item" varStatus="status">
			reportUrlList.push("<c:out value="${item}" escapeXml="false" />");
		</c:forEach>
	}
	
	//==============================================================
	var currentViz = "";
	var vizOptions = {
		hideToolbar : toolbarYn ? ("N" == toolbarYn) : true,
		hideTabs : ishideTabs,
		width : '100%',
		height : '100%',
		device : isDeviceType, //useMobile ? 'phone' : 'desktop',
		toolbarPosition : tableau.ToolbarPosition.BOTTOM // ?????? ?????? ?????? ?????? ?????? ?????????.
	};
	
	/* var pipTableau = new tableau.BI({
		target : $(".viz-chart")[0],
		url : "<c:out value="${reportUrlList[0]}" escapeXml="false" />",
		option : vizOptions
	}); */

	$(window).resize(function() { // ?????? ???????????? ??????
		//resizeViz();
	});

	$(window).bind("orientationchange", function(e) { // ???????????? ?????? ??????
		//location.reload();
	});

	var getUrlParameter = function getUrlParameter(sParam) {
		var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), sParameterName, i;

		for (i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('=');

			if (sParameterName[0] === sParam) {
				return sParameterName[1] === undefined ? true : sParameterName[1];
			}
		}
	};

	// search tableau=====================================================
	$(document).ready(function() {
		// check imageCache
		var imageCacheUseYn = '${configParameter.basicSettingsVo.image_cache_use_yn}';
		var cacheImageName = '${currentMenu.cachingImageName}';
		var m_cacheImageName = '${currentMenu.m_cachingImageName}';

		if ("Y" == imageCacheUseYn) {
			if ("true" == deviceIsMobile) {

				if (!m_cacheImageName) {
					$("#cachingImageWrapper").addClass("hidden");
					$("#reports").width($("#reports-wrapper").width());
					$("#reports").height($(document).height() - 140);
				}
			} else {
				$(".px-content").css("padding-right", "30px");

				if (!cacheImageName) {
					$("#cachingImageWrapper").addClass("hidden");
					$("#reports").width($("#reports-wrapper").width());
					$("#reports").height($(document).height() - 140);
				}
			}
		} else {
			$("#cachingImageWrapper").addClass("hidden");
			$("#reports").height($(document).height() - 150);
		}

		if (tabyn != 'Y') {
			$('#down_excel_workbook').hide();
			$('#down_pdf_workbook').hide();
		}

		//????????? ??????(????????????)??????
		var searchOption = getSearchOption();

		//????????? ????????? ?????? ???????????? load ??????
		if ('${userVo.tableauUserName}' && reportUrlList) {
			
			//????????? ??????
			try {
				for(var i in reportUrlList) {
					var reportSection = $("#reports");
					//var vizHtml = '<div class="viz-chart' + (i != 0 ? ' hidden' : '') + '" id="vizChart' + i + '"></div>';
					var vizHtml = '<div class="viz-chart' + (i != 0 ? ' viz-chart-hidden' : '') + '" id="vizChart' + i + '"></div>';
					
					// reportUrl ???????????? div ?????????
					reportSection.append(vizHtml);
					var viz = new tableau.BI({
						target: $("#vizChart" + i)[0],
						url: reportUrlList[i],
						option: vizOptions
					});
					
					viz.load(searchOption);
					pipTableau["vizChart" + i] = viz;
					
					if("Y" != autoSwitchingYn) {
						break;
					}
				}
			} catch (e) {
				bootbox.alert(e);
			}
			
			var mv_height = $('#menu_nav').css("display") == 'none' ? -5 : $('#menu_nav').height();
			if (ishideTabs) {
				$('#div_param').css('margin-top', (mv_height + 15) + 'px');
			} else {
				$('#div_param').css('margin-top', (mv_height + 38) + 'px');
			}

			//??????????????? ?????? ??????
			if (setting_usermenu_nav_place != '' && setting_usermenu_nav_place != null) {
				if (setting_usermenu_nav_place == 'L') {
					$("#menu_nav").css('text-align', 'left');
					$(".button-section").css("float", "right");
					
					if($(".dataExportDropDown").hasClass("pull-left")) {
						$(".dataExportDropDown").removeClass("pull-left");
					}
					
					$(".dataExportDropDown").addClass("pull-right");
					
				} else if (setting_usermenu_nav_place == 'R') {
					$("#menu_nav").css('text-align', 'right');
					$(".button-section").css("float", "left");
					
					if($(".dataExportDropDown").hasClass("pull-right")) {
						$(".dataExportDropDown").removeClass("pull-right");
					}
					
					$(".dataExportDropDown").addClass("pull-left");
				}
			}

			// frequency ??????
			if (frequency) {
				var frequencyFormat = '<input name="radio_schedule" onclick="frequencyClick(this)" type="radio" value="{0}">{1}', frequencyHtml = '';

				var frequencyKeys = Object.keys(frequency);

				for ( var i in frequencyKeys) {
					frequencyHtml += frequencyFormat.format(frequencyKeys[i], frequency[frequencyKeys[i]]);
					frequencyHtml += '<br>';
				}

				$("#frequency").append(frequencyHtml);
			}

			// ?????? ?????? ????????????
			var selectboxFormat = "<option value={0}>{1}</option>";

			var dayHtml = "";
			for (var j = 1; j <= 31; j++) {
				dayHtml += selectboxFormat.format(j, j);
			}
			dayHtml += selectboxFormat.format('L', '<spring:message code="?????????_??????"/>');

			$("#monthlyDaySelectbox").append(dayHtml);

			// ?????? ????????? ?????? ????????? ?????????
			addDatalistEvent();

			// ????????? ??????
			setCommentEvent();
		}

		//?????? ???????????? ??????
		menuNavCheck();
		
		$('#subscriptionModal').on('hidden.bs.modal', function (e) { 
		    $(this).find('form')[0].reset();
		    $("#subscriptionTarget").empty();
		    window.subscriptionTargetList = [];
		});
		
		// auto switching
		window.needSetupAutoSwitching = true;
	});

	function getSearchOption() {

		var searchOption = [];

		//?????? ???????????? ??????
		var valueArr = [];
		var valueType;
		var valueText;
		var valueForamt;
		if (!$.isEmptyObject(params)) {
			try {
				var key;
				var valueText;
				for ( var i in params) {
					key = params[i].key;
					valueText = params[i].value;
					valueForamt = params[i].format;

					// date format ????????????
					if (!valueForamt && (typeof valueForamt === 'string' || valueForamt instanceof String) && (valueForamt != null && valueForamt.trim() != '')) {
						//?????? ?????? ???????????? ?????? ?????? ??????....
					}

					searchOption.push({
						"field" : key,
						"value" : valueText,
					});
				}
			} catch (e) {
				bootbox.alert('<spring:message code="??????_?????????_??????_?????????_Parameter_????????????_????????????????????????"/>');
			}
		}

		return searchOption;
	}

	function resizeViz() {
	
	}

	/*
	 * Report Load ???...
	 */
	 var tableauViz = null;
	function vizLoadComplate(tableau_viz) {
		tableauViz = tableau_viz;
		// ?????? ??????
		imageTransform(tableau_viz.getParentElement().id);
	}

	function imageTransform(id) {

		var transformBehavior = '${configParameter.basicSettingsVo.image_cache_trans_behavior}';

		if ("${userVo.tableauUserName}") {

			if ($("#cachingImageWrapper").hasClass("hidden") || 'AUTO' === transformBehavior) {
				imageChange(id);
			} else if ('CLICK' === transformBehavior) {
				var msg = "Click to live dashboard.";

				$("#cachingImage").addClass("img-hover");
				$("#cachingImage").attr("title", msg);

				$("#cachingImageWrapper a").css("cursor", "pointer");
				$("#cachingImageWrapper a").on("click", function() {
					imageChange(id);
				});

				toastr.info(msg, "", {positionClass: "toast-top-right", progressBar: true, timeOut: 3000});

			} else {
				imageChange(id);
			}
		}
	}

	function setView(id) {
		//$("#reports").css("width", "auto");
		//$("#reports").css("height", "100%");

		//?????? ????????????
		$('#div_param').show();

		var width = 0;
		var targetEl = $(".viz-chart").not(".viz-chart-hidden");
		var doSetView = (id === $(".viz-chart").not(".viz-chart-hidden").attr("id"));

		// ?????? ???????????? ?????? ??????????????? setView target??? ?????? ??????
		if(doSetView) {
			if (pipTableau[targetEl.attr("id")].viz.getVizSize().sheetSize.maxSize) {
				width = pipTableau[targetEl.attr("id")].viz.getVizSize().sheetSize.maxSize.width + 2;
			}
	
			if (width == 0 || useMobile) {
				$("#reports").css("width", "100%");
				targetEl.find("iframe").css("width", "100%");
				targetEl.css("width", "100%");
			} else {
				
				//mobile??? ???????????? ????????????????????? ??????
				if (useMobile) {
					$('html').css('min-width', $(window).width());
				}
				
				$('html').css('min-width', width);
				targetEl.find("iframe").width(width);
				targetEl.css("min-width", width);
			}
	
			var height = 0;
	
			if (pipTableau[targetEl.attr("id")].viz.getVizSize().sheetSize.maxSize) {
				//height = pipTableau[targetEl.attr("id")].viz.getVizSize().sheetSize.maxSize.height + 29;
				height = pipTableau[targetEl.attr("id")].viz.getVizSize().sheetSize.maxSize.height + 2;
			}
	
			if (height !== 0) {
				
				if (tabyn == 'Y') {
					height += 30;
				}
				
				if(toolbarYn == 'Y') {
					height += 28;
				}
	
				targetEl.height(height);
				//targetEl.find("iframe").height(height + 10);
				targetEl.find("iframe").height(height);
			} else {
				$("#reports").css("height", "100%");
				height = $("body").height() - ($("#reports").offset().top + 10);
				targetEl.height(height);
				//targetEl.find("iframe").height(height);
			}
			
			$("#reports").css("width", "100%");
			$("#reports").css("height", "100%");
		}

		// ?????? ?????? ?????????
		$("#btnSubscription").attr("disabled", false);
		
		targetEl.find("iframe").css("border", "1px solid #e2e2e2");
	}

	function imageChange(id) {
		
		if (!$("#cachingImageWrapper").hasClass("hidden")) {
			$("#cachingImageWrapper").addClass("hidden");
		}

		if ($("#reports").hasClass("hidden")) {
			$("#reports").removeClass("hidden");
		}

		setView(id);

		// ?????? ?????? ??????
		setAutoRefresh();

		// ????????? ????????????
		$(".util-btn-group").has("button").removeClass("hidden");
		
		// ????????????
		var keys = Object.keys(pipTableau);
		if(pipTableau && keys && keys.length > 1) {
			
			if(autoSwitchingYn && "Y" === autoSwitchingYn && needSetupAutoSwitching) {
				needSetupAutoSwitching = false;
				//console.log("set interval");
				
				setAutoSwitching(keys);
			}
		}
		
		if(toastr) {
			toastr.remove();
		}
	}
	
	function setAutoSwitching(keys) {
		setInterval(function() {
			if(window.stopAutoSwitching) {
				return;
			}
			
			for(var i in keys) {
			    var num = keys[i].replace(/[^0-9]/g,"");
			    
			    if($("#vizChart" + num).hasClass("viz-chart-hidden")) {
			    	continue;
			    } else {
			    	var nextTarget;
			    	if($("#vizChart" + (Number(num) + 1))[0]) {
			    		nextTarget = $("#vizChart" + (Number(num) + 1) );
			    	} else {
			    		nextTarget = $("#vizChart0");
			    	}
			    	
			    	pipTableau[keys[i]].viz.refreshDataAsync().always(function(e) {
						// Extend tableau portal session
						fnSessionExtend();
						
						$("#" + keys[i]).addClass("viz-chart-hidden");
				    	pipTableau[keys[i]].viz.hide();
				    	nextTarget.removeClass("viz-chart-hidden");
						pipTableau[nextTarget.attr("id")].viz.show();
						
						setView(nextTarget.attr("id"));
					});
			    	
			    	break;
			    }
			}
		}, autoSwitchingInterval);
	}

	// ?????? ?????? ??????, ?????? ?????? ==============================================
	function menuNavCheck() {
		var selectMenuList = $('.menuHierarchy .px-nav-item.active > a > span ');
		for (var i = 1; i <= selectMenuList.length; i++) {
			$("#menu_nav_step" + i).text(selectMenuList[i - 1].textContent);
			$(".menu_nav_step" + i).show();
			if (selectMenuList.length == i) {
				$(".menu_nav_step" + i).addClass('active');
			}
		}
	}

	// ?????? ???????????? ?????? ?????????
	function openExcelDataPopup(extract) {
		
		
		try {
			var menuName = $("#menuName").text();
			var menuName = $(".rvw_selectMenu > .px-nav-label").text();

			var wurl = pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].getSheetUrl();
			if (extract == '2') {
			} else {
				menuName = pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].getName();
			}
			menuName = encodeURI(menuName);
			wurl = encodeURI(wurl);

			var keys = Object.keys(pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].tableauSearchOption);

			var url_param = "";
			for (var i = 0; i < keys.length; i++) {
				url_param += "&" + encodeURI(keys[i]) + "=" + encodeURI(pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].tableauSearchOption[keys[i]]);
			}
			
			if (excelPopupDown == null || excelPopupDown.closed) {
				//excelPopupDown = window.open('/user/report/downloadPopup/?wurl='+wurl+'&extract='+extract+'&menuName='+menuName+url_param,'excelPopupDown','top=100,left=200,width=500,height=200,resizable=no,scrollbars=no,status=no,titlebar=no');
				excelPopupDown = window.open('/user/report/downloadPopup/?export_type=excel&wurl=' + wurl + '&extract=' + extract + '&menuName=' + menuName + url_param, 'excelPopupDown', 'top=100,left=200,width=500,height=200,resizable=no,scrollbars=no,status=no,titlebar=no');
			}
		} catch (e) {
			console.log(e);
		}
	}

	//PDF ???????????? ?????? ?????????
	function openPdfDataPopup(extract) {
		try {
			var menuName = $(".rvw_selectMenu > .px-nav-label").text();
			var wurl = pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].getSheetUrl();
			if (extract == '2') {
			} else {
				menuName = pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].getName();
			}
			menuName = encodeURI(menuName);
			wurl = encodeURI(wurl);

			var keys = Object.keys(pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].tableauSearchOption);

			var url_param = "";
			for (var i = 0; i < keys.length; i++) {
				url_param += "&" + encodeURI(keys[i]) + "=" + encodeURI(pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].tableauSearchOption[keys[i]]);
			}
			if (pdfPopupDown == null || pdfPopupDown.closed) {
				pdfPopupDown = window.open('/user/report/downloadPopup/?export_type=pdf&wurl=' + wurl + '&extract=' + extract + '&menuName=' + menuName + url_param, 'pdfPopupDown', 'top=100,left=200,width=500,height=200,resizable=no,scrollbars=no,status=no,titlebar=no');
			}
		} catch (e) {
			console.log(e);
		}
	}

	/*
	 * AD-HOC ?????? ????????? URL??? ????????? ?????????
	 */
	function openAdhocWorkbook() {

		// AJAX??? URL ???????????? ????????? ??? URL??? ????????????.
		$.ajax({
			type : "POST",
			url : "/user/report/openAdhocWorkbook",
			cache : false,
			data : {
				pid : _pid,
				mid : _mid
			},
			success : function(response) {
				if (response.resultMessage != '' && response.resultMessage != null) {
					window.open(response.resultMessage, '_blank');
				} else {
					bootbox.alert('<spring:message code="AD-HOC_????????????_???????????????_????????????_???????????????"/>');
				}
			},
			error : function(a, b, c) {
				console.log(a, b, c);
			}
		});
	}

	function showSubscription() {
		
		// ?????? ????????? ??????
		$.ajax({
			url: '/schedule/subscription/task',
			type: 'GET',
			success: function(response) {
				
				if(response && response.success) {
					var subscriptionTasks = response.data;
					
					// ?????? ????????? ?????? set
					var optionHtmlFmt = '<option value="{0}">{1}</option>';
					var optionHtml = '';
					
					if(subscriptionTasks) {
						for(var i in subscriptionTasks) {
							optionHtml += optionHtmlFmt.format(subscriptionTasks[i].schedule_id, subscriptionTasks[i].schedule_name);
						}
						
						$("#subscriptionSchedule").html(optionHtml);
					}
					
					// ??????
					//$("input[name=title]").val(pipTableau[$(".viz-chart").not(".viz-chart-hidden").attr("id")].getName() || "");
					$("input[name=title]").val("[Tableau Subscription] " + nMenuVo.name);
					
					// ???????????? ???????????? ????????? ?????? ???????????? ??????. ????????? ??????
					if ('${userVo.adminYn}' == 'N') {
						subscriptionTargetList.push('${userVo.seq}');
					}
					
					$("#subscriptionModal").modal("show");
				} else {
					bootbox.alert('Error during get subscription tasks.');
				}
			},
			error: function(response) {
				bootbox.alert('Error during get subscription tasks.');
			}
		});
	}

	function frequencyClick(radio) {
		var val = $(radio).val();

		showDetailTimeField(val);
	}

	function showDetailTimeField(value) {
		for ( var i in detailTimeIdList) {
			if (detailTimeIdList[i] === value) {
				$("#" + detailTimeIdList[i]).removeClass('hidden');
			} else {
				if (!$("#" + detailTimeIdList[i]).hasClass('hidden')) {
					$("#" + detailTimeIdList[i]).addClass('hidden');
				}
			}
		}
	}

	function saveSubscription() {

		var form = $("#subscriptionModal").find("form"), 
			params = {};

		if (form[0]) {

			if (!$.isEmptyObject(subscriptionTargetList)) {
				
				if(!$("#subscriptionSchedule").val()) {
					bootbox.alert('<spring:message code="?????????_???????????????_????????????"/>');
					return;
				}
				
				
				// ?????? ??????
				params.subscription = [];
				
				var scheduleId = $("#subscriptionSchedule").val();
				var title = $("#subscriptionTitle").val();
				var content = $("#subscriptionContent").val().replace(/\n/ig, '<br>');

				for ( var i in subscriptionTargetList) {
					params.subscription.push({
						userSeq : subscriptionTargetList[i],
						pid: _pid,
						mid : currentMenuId,
						scheduleId: scheduleId,
						title: title,
						content: content,
						regUserId: "${userVo.userId}"
					});
				}

				$.ajax({
					url : '/user/report/subscription',
					type : 'POST',
					data : JSON.stringify(params),
					dataType : 'JSON',
					contentType : 'application/json',
					success : function(response) {
						if (response.success) {
							if (response.message) {
								bootbox.alert(response.message);
							} else {
								bootbox.alert('<spring:message code="??????_??????"/>');
							}

							$("#subscriptionModal").modal("hide");
						} else {
							if (response.message) {
								bootbox.alert(response.message);
							} else {
								bootbox.alert('<spring:message code="??????_??????"/>');
							}
						}
					},
					error : function(response) {
						if (response && response.message) {
							bootbox.alert(message);
						}
					}
				});

			} else {
				bootbox.alert('<spring:message code="??????_?????????_???????????????" />');
			}
		}
	}

	function selectDataList(e) {
		var input = e.target, 
			list = input.getAttribute('list'), 
			options = document.querySelectorAll('#' + list + ' option'), 
			showTarget = $("#subscriptionTarget"), 
			inputValue = input.value;

		for (var i = 0; i < options.length; i++) {
			var option = options[i];

			if (option.value === inputValue) {
				var dataValue = option.getAttribute("data-value");

				if (subscriptionTargetList.indexOf(dataValue) == -1) {
					subscriptionTargetList.push(dataValue);
					showTarget.append('<div id="' + dataValue + '" class="target-box"><div class="target-box-name"><span>' + inputValue + '</span></div><div class="target-box-remove" onclick="removeTarget(this)"><span>X</span></div></div>');
				}

				// input clear
				$(input).val(null);

				break;
			}
		}
	}

	function addDatalistEvent() {
		$('input[list]').on({
			'keyup' : function(e) {
				if (e.keyCode == '13') {
					selectDataList(e);
				}
			},
			'change' : function(e) {
				selectDataList(e);
			}
		});
	}

	function removeTarget(el) {
		var id = $(el).parent('div.target-box').attr('id');

		subscriptionTargetList = $.grep(subscriptionTargetList, function(value) {
			return value != id
		});
	
		$("#" + id).remove();
	}

	// comment ?????????
	function setCommentEvent() {
		$("#commentSection .comment-panel").comments({
			profilePictureURL : '${resourcesPath}/images/icon/user-icon.png',
			//roundProfilePictures: true,
			textareaRows : 1,
			enableAttachments : false,
			enableUpvoting : false,
			enableNavigation : false,
			enableDeletingCommentWithReplies : true,
			enableDeleting : true,
			enableEditing : true,
			highlightColor : '#23A6F0',
			getComments : function(success, error) {

				var params = {
					mid : window.currentMenuId
				};

				$.ajax({
					type : 'GET',
					url : '/menu/comment',
					data : params,
					dataType : "JSON",
					success : function(result) {
						if (result && result.success) {
							if ($.isArray(result.data)) {
								success(result.data);
							} else {
								success([]);
							}
						}
					},
					error : error
				});

			},
			postComment : function(data, success, error) {
				if (window.currentMenuId) {
					data.mid = window.currentMenuId || null;

					data.id = data.mid + "_" + data.id + '_' + new Date().getTime();
					data.portalId = "${userVo.userId}";
					
					data.fullname = data.portalId;

					data.created = moment(data.created).format("YYYY-MM-DD HH:mm:ss");
					data.modified = moment(data.created).format("YYYY-MM-DD HH:mm:ss");

					$.ajax({
						type : 'POST',
						cache : false,
						url : '/menu/comment',
						data : data,
						dataType : "JSON",
						success : function(result) {
							success(data);
						},
						error : error
					});
				}
			},
			putComment : function(data, success, error) {
				data.mid = window.currentMenuId;

				if (data.modified) {
					var modifiedDate = new Date(data.modified);
					if (!isNaN(modifiedDate)) {
						data.modified = moment(modifiedDate).format("YYYY-MM-DD HH:mm:ss");
					}
				}

				$.ajax({
					type : 'PUT',
					contentType : 'application/json',
					url : '/comment',
					data : JSON.stringify(data),
					dataType : "JSON",
					success : function(result) {
						success(data);
					},
					error : error
				});
			},
			deleteComment : function(data, success, error) {
				data.mid = window.currentMenuId;

				$.ajax({
					type : 'DELETE',
					contentType : 'application/json',
					url : '/comment',
					data : JSON.stringify(data),
					dataType : "JSON",
					success : function(result) {
						success(data);
					},
					error : error
				});
			},
			upvoteComment : function(data, success, error) {
				setTimeout(function() {
					success(data);
				}, 500);
			},
			uploadAttachments : function(dataArray, success, error) {
				setTimeout(function() {
					success(dataArray);
				}, 500);
			},
		});
	}

	var tmp = 1;
	var autoRefreshInterval;
	var refreshBtnHtml = $("#autoRefreshSection").html();
	var isPaused = false;

	function setAutoRefresh() {
		var autoRefreshUseYn = '${configParameter.basicSettingsVo.auto_refresh_use_yn}';
		var autoRefreshTime = "${currentMenu.autoRefreshTime}";
		if ("Y" === autoRefreshUseYn && autoRefreshTime) {
			autoRefreshTime = autoRefreshTime * 1;
			if (!isNaN(autoRefreshTime) && autoRefreshTime > 0) {
				// tableau automatic refresh ?????? ???
				// pipTableau.viz.pauseAutomaticUpdatesAsync();
				
				// ?????? ????????????.
				$("#autoRefreshSection").html(refreshBtnHtml + '<spring:message code="n???_???_??????_??????"/>'.format(autoRefreshTime));
				if ($("#autoRefreshSection").hasClass("hidden")) {
					$("#autoRefreshSection").removeClass("hidden");
				}
				
				autoRefreshInterval = setInterval(function() {
					if (!isPaused) {
						var tmp2 = autoRefreshTime - tmp;

						if (tmp2 == 0) {
							// ?????? ???????????? ????????? ??????
							for(var i in pipTableau) {
								pipTableau[i].viz.refreshDataAsync().always(function(e) {
									// Extend tableau portal session
									fnSessionExtend();
								});
							}
							
							tmp = 0;
						}

						$("#autoRefreshSection").html(refreshBtnHtml + '<spring:message code="n???_???_??????_??????"/>'.format((tmp2 < 0 ? 0 : tmp2)));

						tmp += 1;
					}
				}, 1000);
			}
		}
	}

	function onClickAutoRefresh() {
		isPaused = !isPaused;

		var span = $("#autoRefreshSection span"), resumeClass = "fa-play", pauseClass = "fa-pause";

		if (span.hasClass(pauseClass)) {
			span.removeClass(pauseClass);
			span.addClass(resumeClass);
		} else if (span.hasClass(resumeClass)) {
			span.removeClass(resumeClass);
			span.addClass(pauseClass);
		}
	}

	function showFullScreen() {
		//var target = $(".viz-chart iframe").get(0);
		var target = $("#reports").get(0);
		if (target) {
			if (document.fullscreenElement || document.webkitFullscreenElement
					|| document.mozFullScreenElement
					|| document.msFullscreenElement) {
				if (document.exitFullscreen) {
					document.exitFullscreen();
				} else if (document.mozCancelFullScreen) {
					document.mozCancelFullScreen();
				} else if (document.webkitExitFullscreen) {
					document.webkitExitFullscreen();
				} else if (document.msExitFullscreen) {
					document.msExitFullscreen();
				}
			} else {
				if (target.requestFullscreen) {
					target.requestFullscreen();
				} else if (target.mozRequestFullScreen) {
					target.mozRequestFullScreen();
				} else if (target.webkitRequestFullscreen) {
					target.webkitRequestFullscreen();
				} else if (target.msRequestFullscreen) {
					target.msRequestFullscreen();
				}
			}
		}
	}
	
	function checkHour(field) {
		var val = $(field).val() * 1;
			
		if(!val || isNaN(val) || val > 23 || val < 0) {
			$(field).val(0);
		} else {
			$(field).val(val);
		}
	}

	function checkMinute(field) {
		var val = $(field).val() * 1;
		
		if(!val || isNaN(val) || val > 59 || val < 0) {
			$(field).val(0);
		} else {
			$(field).val(val);
		}
	}
	
	// info popup
	function viewInfo() {
		if (nMenuVo && nMenuVo.mid) {
			var url = '/info/view?mid=' + nMenuVo.mid, w = window.open(url, '',
							'top=10, left=10, status=1, location=1, resizable=1, width=800, height=850');

			w.focus();
		} else {
			console.log("menu vo??? ????????????.");
		}
	}
</script>
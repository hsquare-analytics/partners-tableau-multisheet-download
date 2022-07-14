
//Tableau API
(function($) {
	"use strict";
	window.tableau = window.tableau || {};
	
	window.tableau.BI = function(args) {

		this.tableauSearchOption = {};
		this.viz=null;
		this.INIT_EVENT = "initialized";
		this.alertMessage = "현재 분석 실행 중입니다. 잠시만 기다려 주세요.";
		this.loadCompleteVizList = [];
		this.loadCompleTargetVizList = [];
		this.htmlTarget = [];
		this.initOption = [];
		this.pipOption = [];
		this.vizList = [];
		this.url = [];
		var $this = this;
		var loadDelayMillis = 100;
		var loadWaitMaximumSec = 60;
		var options = [];
		var useRefreshDataAsync = true;
		var autoLoad = true;
		
		this.setTableau = function(tablauListView) {
			var tablauListViewLength = tablauListView.length;
			for (var i=0; i<tablauListViewLength; i++) {
				var option = tablauListView[i];
				options.push(option);
				this.htmlTarget.push(option["target"]);
				this.url.push(option["url"]);
				this.initOption.push(option["option"]);
				var pipOption = option["pipOption"];
				this.pipOption.push(pipOption);
				if (pipOption) {
					if (pipOption.autoLoad) {
						$this.loadTableau(option["target"], option["url"], option["option"], pipOption, i * loadDelayMillis);
					}
				}
			}
		};
		
		this.onFirstInteractive = function(event) {
			if ($this.loadCompleteVizList.indexOf(event.getViz()) < 0) {
				$this.loadCompleteVizList.push(event.getViz());
				vizLoadComplate(event.getViz());
			}
		};
		
		this.loadTableau = function(target, url, option, pipOption, delay) {
			setTimeout(function() {
				pipOption = $.extend({}, pipOption);
				
				if (typeof pipOption.offOverlapCheck == "undefined" || pipOption.offOverlapCheck !== true) {
					if (!option.onFirstInteractive) {
						option.onFirstInteractive = $this.onFirstInteractive;
					}
				}
				//"?:embed=yes&:embed=y&:showAppBanner=false&:showShareOptions=true&:display_count=no&:showVizHome=no&:jsdebug=false"
				if(url.indexOf("?") < 0){
					url += "?";
				} else{
					url += "&";
				}
				
				//url += ":jsdebug=false&:refresh=yes";
				
				var viz = new tableau.Viz(target, url, option);
				$this.viz = viz;
				$this.vizList.push(viz);
				
				if (typeof pipOption.offOverlapCheck == "undefined" || pipOption.offOverlapCheck !== true) {
					$this.loadCompleTargetVizList.push(viz);
					viz.addEventListener(tableau.TableauEventName.FILTER_CHANGE, function(event) {
						if ($this.loadCompleteVizList.indexOf(event.getViz()) < 0) {
							$this.loadCompleteVizList.push(event.getViz());
						}
						// var fname = event.getFieldName();
						 event.getFilterAsync().then(function(param){
						      //alert(''+param.getFieldName() +' of Type '+param.getFilterType() +' has value '+param.getAppliedValues()[0].formattedValue);
						     var dataName = param.getFieldName();
							 var dataType = param.getFilterType();
							 var values   = '';
							 if(dataType == 'categorical'){
								 for (var i = 0; i < param.getAppliedValues().length; i++) {
									 if(i!=0){
										 values+=',';
									 }
									 values+= param.getAppliedValues()[i].formattedValue;
								 }
							// range의 경우 소스점이나 너무 큰 범위 일 경우 처리가 곤란함으로
							// tableau에서 파라미터로 처리하는 것이 바람직함.
							 }else if(dataType == 'quantitative'){
								 /*var max = parseInt(param.getMax().value);
								 var min = parseInt(param.getMin().value);
								 for (var i = min; i <=max; i++) {
									 if(i==min){
										 values= i;
									 }else{
										 values+= ","+i;
									 }
								}*/
								 return;
							 }else if(dataType == 'string'){
								 values= param.getAppliedValue().formattedValue;
							 }else if(dataType == 'boolean'){
								 values= param.getAppliedValue().value;
							 }else if(dataType == 'integer'){
								 values= param.getAppliedValue().formattedValue;
							 }else if(dataType == 'float'){
								 values= param.getAppliedValue().formattedValue;
							 }else if(dataType == 'date'){
								 values= param.getAppliedValue().formattedValue;
							 }else{
								 values= param.getAppliedValue().formattedValue;
							 }
							 if(values == undefined){
								 values == '';
							 }
							 $this.setTableauSearchOption(dataName,values);
						   });
						//
					});
					viz.addEventListener(tableau.TableauEventName.PARAMETER_VALUE_CHANGE, function(event) {
						if ($this.loadCompleteVizList.indexOf(event.getViz()) < 0) {
							$this.loadCompleteVizList.push(event.getViz());
						}

						// var fname = event.getParameterName();
						 event.getParameterAsync().then(function(param){
						      //alert(''+param.getName()  +' of Type '+param.getDataType() +' has value '+param.getCurrentValue().formattedValue);
						      var dataName = param.getName();
						      var dataType = param.getDataType()  ;
						      var values   = '';
								 if(dataType == 'categorical'){
									 for (var i = 0; i < param.getCurrentValues().length; i++) {
										 if(i!=0){
											 values+=',';
										 }
										 values+= param.getCurrentValues()[i].formattedValue;
									 }
								 }else if(dataType == 'string'){
									 values= param.getCurrentValue().formattedValue;
								 }else if(dataType == 'boolean'){
									 values= param.getCurrentValue().value;
								 }else if(dataType == 'integer'){
									 values= param.getCurrentValue().formattedValue;
								 }else if(dataType == 'float'){
									 values= param.getCurrentValue().formattedValue;
								 }else if(dataType == 'date'){
									 values= param.getCurrentValue().formattedValue;
								 }else{
									 values= param.getCurrentValue().formattedValue;
								 }
								 if(values == undefined){
									 values == '';
								 }
								 $this.setTableauSearchOption(dataName,values);
						   });
						//
					});
				}
				
				if (pipOption && pipOption.isTabSwicher) {
					viz.addEventListener(tableau.TableauEventName.TAB_SWITCH, function (e) {
						var viz = e.getViz();
						window.viz = viz;
						var newSheetName = e.getNewSheetName();
						
						viz.getWorkbook().getActiveSheet().getWorksheets()[0].getFiltersAsync().then(function(promise) {  
							if (promise.length > 0) {
								var fieldName = promise[0].getFieldName();
								fieldName = fieldName.substring(fieldName.indexOf("(") + 1, fieldName.indexOf(")"));
								var fields = fieldName.split(",");
								var variables = promise[0].getAppliedValues();
								var values = [];
								for (var i=0; i<variables.length; i++) {
									var valueSplit = variables[i].formattedValue.split(",");
									for (var j=0; j<valueSplit.length; j++) {
										values.push(valueSplit[j].trim());
									}
								}
								for (var j=0; j<$this.vizList.length; j++) {
									if ($this.vizList[j] == viz) continue;
									$this.vizList[j].getWorkbook().activateSheetAsync(newSheetName.replace("(C)", "(D)")).then(function() {
										for (var i=0; i<fields.length; i++) {
											$this.vizList[1].getWorkbook().getActiveSheet().getWorksheets()[0].applyFilterAsync(fields[i], values[i], tableau.FilterUpdateType.REPLACE);
										}
									});
								}
							} // End promise.length
						}); // End getFiltersAsync
					}); // End TAB_SWITCH EventListener
				} // End if (pipOption.isTabSwicher) {
			}, delay);
		};
		
		// dispose
		this.dispose = function() {
			for (var i=0; i<this.vizList.length; i++) {
				this.vizList[i].dispose();
			}
			this.vizList = [];
			this.htmlTarget = [];
			this.initOption = [];
			this.pipOption = [];
			this.vizList = [];
			this.url = [];
			this.loadCompleteVizList = [];
			this.loadCompleTargetVizList = [];
			options = [];
		};
		
		// 이미지 다운로드
		this.downloadImage = function() {
			if (this.vizList.length > 0) {
				this.vizList[0].showExportImageDialog();
			}
		};
		
		// 데이터 다운로드
		this.downloadData = function() {
			if (this.vizList.length > 0) {
				this.vizList[this.vizList.length-1].showExportCrossTabDialog()
			}
		};
		
		this.getName = function(){
			if (this.vizList.length > 0) {
				return this.vizList[0].getWorkbook().getActiveSheet().getName();
			}
		}
		this.getSheetUrl = function(){
			if (this.vizList.length > 0) {
				return this.vizList[0].getWorkbook().getActiveSheet().getUrl();
			}
		}
		// 데이터 다운로드_Excel
		this.downloadExcelData = function(parameters) {
		
			if (this.vizList.length > 0) {
				var searchOption = "";
				for (var i=0; i<parameters.length; i++) {
					searchOption += "&"+parameters[i].field+"="+encodeURI(parameters[i].value);
				}
				$.ajax({type : "POST",
					url: "/portal/excel/download",
					cache: false,
					isIndicatorShowing : false,
					data: {
						extractOption : "1",
						exportUrl : this.url[this.vizList.length-1],
						params : searchOption
					},
					success: function(response) {
						if (response.resultCode == -2) {
							console.log(response.resultCode);
						} else {
							
							bootbox.alert({message: response.resultMessage,
								callback: function() {
									//location.reload();
								}
							});
						}
					},
					error: function(a, b, c) {
						console.log(a, b, c);
					}
				});
				//this.vizList[this.vizList.length-1].showExportCrossTabDialog()
			}
		};
	
		// load
		this.load = function(parameters) {
			if(parameters && parameters.length>0){
				for (var i=0; i<parameters.length; i++) {
					this.tableauSearchOption[parameters[i].field] = parameters[i].value;
				}
				
			}
			// init
			if (this.vizList.length == 0) {
				var searchOption = {};
				for (var i=0; i<parameters.length; i++) {
					searchOption[parameters[i].field] = parameters[i].value;
				}
				for (var i=0; i<options.length; i++) {
					var loadOption = $.extend({}, searchOption, this.initOption[i]);
					var index = i;
					$this.loadTableau($this.htmlTarget[index], $this.url[index], loadOption, options[i]["pipOption"], i * loadDelayMillis);
				}
			// update
			} else {
				if ($this.loadCompleTargetVizList.length > $this.loadCompleteVizList.length) {
					alert($this.alertMessage);
					return;
				}
				var method = "";
				for (var i=0; i<parameters.length; i++) {
					var param = parameters[i];
					if (param.type == TYPE_PARAMETER) {
						this.setParameter(param.field, param.value);
					} else if (param.type == TYPE_FILTER) {
						this.setFilter(param.field, param.value);
					}
				}
				if (useRefreshDataAsync) {
					for (var i=0; i<$this.vizList.length; i++) {
						$this.vizList[i].refreshDataAsync();
					}
				}
				$this.loadCompleteVizList = [];
			}

			setTimeout(function() {
				$this.loadCompleteVizList = $this.loadCompleTargetVizList;
			}, loadWaitMaximumSec * 1000);
		};
		
		this.setTableauSearchOption = function(field,value){
			this.tableauSearchOption[field] = value;
		}
		
		// 필터
		this.setFilter = function(field, value) {
			for (var i=0; i<this.vizList.length; i++) {
				var worksheetLength = this.vizList[i].getWorkbook().getActiveSheet().getWorksheets().length;
				for (var j=0; j<worksheetLength; j++) {
					this.vizList[i].getWorkbook().getActiveSheet().getWorksheets()[j].applyFilterAsync(field, value, tableau.FilterUpdateType.REPLACE);
				}
			}
		};
		
		// 파라미터 변경
		this.setParameter = function(field, value) {
			for (var i=0; i<this.vizList.length; i++) {
				this.vizList[i].getWorkbook().changeParameterValueAsync(field, value);
			}
		};
		
		var argumentsList = [];
		for (var i=0; i<arguments.length; i++) {
			argumentsList.push(arguments[i]);
		}
		
		this.setTableau(argumentsList);
		
		return this;
	};
	
})(jQuery);


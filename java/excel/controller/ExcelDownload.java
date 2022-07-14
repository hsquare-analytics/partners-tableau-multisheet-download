package com.planit.tableau.portal.standard.v1.excel.controller;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.core.Cookie;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.util.HtmlUtils;

import com.planit.tableau.portal.standard.v1.common.configuration.ConfigParameter;
import com.planit.tableau.portal.standard.v1.common.controller.TableauBaseController;
import com.planit.tableau.portal.standard.v1.common.utils.CommonUtil;
import com.planit.tableau.portal.standard.v1.common.utils.FileDownload;
import com.planit.tableau.portal.standard.v1.common.utils.StringUtil;
import com.planit.tableau.portal.standard.v1.common.vo.CommonDefaultVO;
import com.planit.tableau.portal.standard.v1.excel.bindings.BootstrapRequest;
import com.planit.tableau.portal.standard.v1.excel.bindings.BootstrapResponse;
import com.planit.tableau.portal.standard.v1.excel.bindings.WorkSheetList;
import com.planit.tableau.portal.standard.v1.excel.bindings.WorkSheetType;
import com.planit.tableau.portal.standard.v1.tableau.bindings.TableauCredentialsType;
import com.planit.tableau.portal.standard.v1.tableau.restapi.RestApiUtils;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.core.util.MultivaluedMapImpl;

/**
 * 엑셀 다운로드
 * 
 * @author Planit-Partners
 */
@Controller
public class ExcelDownload extends TableauBaseController {

	private static Logger logger = LoggerFactory.getLogger(ExcelDownload.class);

	/**
	 * 태블로 인터페이스
	 */
	@Autowired
	RestApiUtils tableauAPI;

	// @Autowired
	// private TableauUserDAO tableauUserDao;
	//
	// @Autowired
	// private ScheduleFileManageDAO scheduleFileManageDAO;

	// @Autowired
	// private Message message;

	/**
	 * config class
	 */
	@Autowired
	private ConfigParameter configParameter;

	private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
	// private static final String APPLICATION_EXCEL =
	// "application/vnd.ms-excel";

	/**
	 * 엑셀 다운로드 파일
	 */
	@RequestMapping(value = "/excel/downloadFile", method = { RequestMethod.POST, RequestMethod.GET })
	//@Transactional
	public void downloadFile(HttpServletRequest request, HttpServletResponse response) throws Exception {

		try {
			String filePath = getPublicDir() + "/";
			String fileName = request.getParameter("fileName");
			String aliasName = request.getParameter("aliasName");

			FileDownload.downAlias(request, response, filePath, fileName, aliasName);
		} catch (Exception e) {
			logger.error(e.toString());
			logger.error(CommonUtil.getStackTrace(e));
		}

	}

	/**
	 * 엑셀 다운로드
	 * 
	 * @param
	 * @return CommonDefaultVO
	 * @throws IOException
	 * @throws JSONException
	 */

	@PostMapping(value = "/excel/download")
	//@Transactional
	public @ResponseBody CommonDefaultVO download(HttpServletRequest request, HttpServletResponse response) throws JSONException, IOException {

		// 로직 수정 필요 ##############
		// 결과 코드
		int resultCode = -1;
		// 결과 메시지
		String resultMessage = "";

		try {
			String exportUrl = request.getParameter("exportUrl").replaceAll("trusted/.*?/", "");
			String extractOption = request.getParameter("extractOption");
			String params = HtmlUtils.htmlUnescape(request.getParameter("params"));
			logger.debug(params);
			boolean createExcelResult = false;
			String downloadPath = getPublicDir() + "/";// request.getServletContext().getRealPath("/");
			Timestamp timestamp = new Timestamp(System.currentTimeMillis());
			String fileName = "excelDownload^_" + sdf.format(timestamp) + ".xlsx";
			downloadPath += fileName; // xlsx file address
			// 사용자 세션에서 태블로 credentials 반환
			TableauCredentialsType credentials = getAdminCredentials();
			if (credentials == null) {
				resultCode = -1;
				// resultMessage = "인증정보가 없습니다. 확인 부탁드립니다.";
				resultMessage = getMessage("인증정보가_없습니다") + "\n" + getMessage("확인_부탁드립니다");
				logger.error("ExcelDownload - 관리자 인증정보가 없습니다.");
			} else {
				createExcelResult = excelDownload(exportUrl, extractOption, params, downloadPath, credentials);
				// 성공
				if (createExcelResult) {
					resultCode = 0;
					resultMessage = fileName;
					// 실패
				} else {
					resultCode = -1;
					resultMessage = getMessage("시스템에러메시지");
				}
			}
		} catch (Exception e) {
			logger.error(CommonUtil.getStackTrace(e));
		}

		return CommonDefaultVO.getNewInstance(resultCode, resultMessage);
	}

	/*
		*//**
			 * 스케줄 강제실행 다운로드
			 *//*
				 * public boolean scheduleDownload(String fileName, String
				 * exportUrl, String exportMonth) throws
				 * UnsupportedEncodingException {
				 * 
				 * // params : exportMonth String downloadPath = getPublicDir()
				 * + "/" + exportMonth + "/"; File excelPath = new
				 * File(downloadPath); if (!excelPath.exists()) {
				 * excelPath.mkdirs(); } String params = ""; try { params = "&"
				 * + URLEncoder.encode("매개_년월", "UTF-8") + "=" +
				 * exportMonth.replaceAll("-", ""); } catch
				 * (UnsupportedEncodingException e1) { // TODO Auto-generated
				 * catch block e1.printStackTrace(); } List<TableauUserVO>
				 * tableauAdminList = tableauUserDao.findAdmin(); TableauUserVO
				 * tableauAdminVO = tableauAdminList.get(0);
				 * TableauCredentialsType credentials = null; if
				 * (configParameter.getTableauAdminSaveType().equals(
				 * ConfigParameter.TABLEAU_ADMIN_SAVE_TYPE_CONFIG)) {
				 * credentials =
				 * tableauAPI.invokeSignIn(configParameter.getTableauAdminName()
				 * , configParameter.getTableauAdminPw(), ""); } else {
				 * credentials =
				 * tableauAPI.invokeSignIn(tableauAdminVO.getName(),
				 * tableauAdminVO.getPassword(), ""); }
				 * 
				 * boolean createExcelResult = false; //
				 * insertScheduleData(exportMonth);
				 * 
				 * Timestamp timestamp = new
				 * Timestamp(System.currentTimeMillis());
				 * 
				 * String realName = "excelDownload^_" + sdf.format(timestamp) +
				 * ".xlsx"; String exportPath = downloadPath + realName; // xlsx
				 * file address try { createExcelResult =
				 * excelDownload(exportUrl, "2", params, exportPath,
				 * credentials); if (createExcelResult) {
				 * insertScheduleFile(exportMonth, fileName, realName); } }
				 * catch (JSONException e) { // TODO Auto-generated catch block
				 * e.printStackTrace(); } catch (IOException e) { // TODO
				 * Auto-generated catch block e.printStackTrace(); }
				 * 
				 * return createExcelResult; }
				 * 
				 * 
				 * 스케줄 파일 추가
				 * 
				 * public void insertScheduleFile(String month, String fileName,
				 * String realName) { ScheduleFileManageVO scheduleFileManageVO
				 * = new ScheduleFileManageVO();
				 * scheduleFileManageVO.setMonth(month);
				 * scheduleFileManageVO.setFileName(fileName);
				 * scheduleFileManageVO.setRealName(realName);
				 * 
				 * List<ScheduleFileManageVO> listSchedule =
				 * scheduleFileManageDAO.findMonthAndName(scheduleFileManageVO);
				 * 
				 * if (listSchedule.isEmpty()) { //
				 * scheduleFileManageVO.setId();
				 * scheduleFileManageDAO.nextVal(scheduleFileManageVO);
				 * scheduleFileManageDAO.insert(scheduleFileManageVO); } else {
				 * scheduleFileManageDAO.update(scheduleFileManageVO); } }
				 */
	public boolean excelDownload(String exportUrl, String extractOption, String params, String downloadPath, TableauCredentialsType credentials)
			throws JSONException, IOException {

		exportUrl = exportUrl.split("/views")[1];
		if (exportUrl.indexOf('?') >= 0) {
			exportUrl = exportUrl.split("\\?")[0];
		}

		params = URLDecoder.decode(params, "UTF-8");
		params = com.mysema.commons.lang.URLEncoder.encodeURL(params);

		String tableauHost = configParameter.getTableauHostUrl();

		String url = tableauHost + "/views" + exportUrl + "?:embed=yes&:from_wg=true&" + params;

		BootstrapRequest bootRequest = new BootstrapRequest();
		BootstrapResponse bootResponse = new BootstrapResponse();

		// 사용자 세션에서 태블로 credentials 반환
		// TableauCredentialsType credentials =getAdminCredentials();
		// 무조건 관리자 토큰을 가지고 있는다.

		// 경로 확인
		// http://52.231.76.61:8000/views/TestPerformance/School-LevelEvaluation?:embed=yes&:from_wg=true&showVizHome=no&pyear=2018&pmonth=201802&pdate=20180219&=
		// http://52.231.76.61:8000/vizql/w/SalesReport-Estimate/v/1/exportcrosstab/sessions/6CFE254411924FC6B356732C68D5BB6D-0:0/views/13898457173773695894_11441046272256559412?charset=utf16&download=true&nodata=true

		// 첫번째 요청 현재 Url 정보 및 통합문서 대시보드 List 가져옴

		// tapi버전이 아닌, server 버전가져오도록...
		// String tableauApiVersionStr = configParameter.getTableauApiVersion();
		String tableauServerVersionStr = configParameter.getTableauServerVersion();

		// 소수점일경우 NumberFormatException으로 long -> double로 변경
		// Double tableauApiVersion = Double.parseDouble(tableauApiVersionStr);
		Double tableauServerVersion = Double.parseDouble(tableauServerVersionStr);

		if (tableauServerVersion < 10.3) {
			String firstResponse = getReportViewFirst_under_10_3(url, credentials);
			bootRequest = extractFirstResponse_under_10_3(firstResponse, params);
		} else {
			JSONObject firstResponse = getReportViewFirst(url, credentials);
			bootRequest = extractFirstResponse(firstResponse);
		}

		// String workbookName = bootRequest.getWorkbookName();

		// 대시보드 url
		ArrayList<String> workBookSheetListUrl = new ArrayList<String>();
		// 대시보드 이름
		ArrayList<String> workBookSheetListName = new ArrayList<String>();

		// 추출 옵션 : 현재페이지 다운 = 1, 통합문서 다운 = 2
		if (extractOption.equals("1")) {
			workBookSheetListUrl.add(bootRequest.getVizqlRoot());
			workBookSheetListName.add(bootRequest.getSheet_id());
		} else if (extractOption.equals("2")) {
			ArrayList<String> workBookSheetList = new ArrayList<String>();
			workBookSheetList.addAll(JSONArrayToArrayList(bootRequest.getRepository_urls()));
			workBookSheetListUrl = urlToVizRoot(workBookSheetList);
			workBookSheetListName.addAll(JSONArrayToArrayList(bootRequest.getVisible_sheets()));
		}

		// url 갯수만큼 반복 실행
		LinkedHashMap<String, WorkSheetList> workbook = new LinkedHashMap<String, WorkSheetList>();

		for (int idx = 0; idx < workBookSheetListUrl.size(); idx++) {

			String workBookSheetName = workBookSheetListName.get(idx).toString().trim();
			String workBookSheetUrl = workBookSheetListUrl.get(idx).toString();
			String sessionId = bootRequest.getSessionId();// basic Session ID
			String sessionUrl = getBootstrapSessionUrl(workBookSheetUrl, sessionId);

			// 두번째 요청 Url의 워크시트 정보를 가져옴.
			bootRequest.setSheet_id(workBookSheetName);
			String secondResponse = getReportViewSecond(sessionUrl, bootRequest, credentials);
			bootResponse = extractSecondResponse(secondResponse);
			// logger.debug(secondResponse);
			// 두번째 SessionId가 빈 값으로 오는 경우가 있음.
			String newSessionId = bootResponse.getNewSessionId();
			logger.debug("newSessionId : " + newSessionId);
			if (newSessionId != null && newSessionId.length() != 0) {
				sessionId = newSessionId;
			}

			// 워크시트 리스트.
			JSONObject viewObj = bootResponse.getViewIds();
			WorkSheetList workSheetList = new WorkSheetList();

			// 워크시트 갯수만큼 반복하면서 crosstab 추출
			Iterator<?> i = viewObj.keys();
			while (i.hasNext()) {
				String key = i.next().toString();
				String downloadUrl = tableauHost + workBookSheetUrl + "/exportcrosstab/sessions/" + sessionId + "/views/" + viewObj.getString(key)
						+ "?charset=utf8&download=true";
				WorkSheetType extractResult = requestExtractCrossTab(key, downloadUrl, credentials);
				workSheetList.getWorkSheet().add(extractResult);
			}
			// 추출 csv 저장
			workbook.put(workBookSheetName, workSheetList);
		}

		boolean createExcelResult = true;

		createExcelResult = csvToXLSX(workbook, downloadPath);
		return createExcelResult;
	}

	public String tsConfigDecode(String tsConfigString) {
		String decodeResult = HtmlUtils.htmlUnescape(tsConfigString);
		decodeResult = decodeResult.replaceAll("<textarea id=\"tsConfigContainer\">", "");
		decodeResult = decodeResult.replaceAll("</textarea>", "");
		// logger.debug(decodeResult);
		return decodeResult;
	}

	public String tsConfigDecode_under_10_3(String tsConfigString) {
		String decodeResult = decodeHexEscapes(tsConfigString);
		decodeResult = decodeResult.replaceAll("tsConfig = ", "");
		decodeResult = decodeResult.replaceAll("};", "}");
		// logger.debug(decodeResult);
		// decodeResult = decodeResult.replaceAll("\\n", "");

		// logger.debug(value);
		// logger.debug(decodeResult);
		return decodeResult;
	}

	public String decodeHexEscapes(String str) {
		Pattern pattern = null;
		pattern = Pattern.compile("\\\\x([a-fA-F0-9]{2})");

		StringBuffer sb = new StringBuffer();
		Matcher match = pattern.matcher(str);

		while (match.find()) { // 패턴 매칭 확인
			String convert = hexToString(match.group(1));
			match.appendReplacement(sb, convert);
		}
		match.appendTail(sb);
		// logger.debug(sb.toString());
		return sb.toString();
	}

	public String hexToString(String hex) {
		return Character.toString((char) Integer.parseInt(hex, 16));
	}

	public JSONObject tsConfigParser(String str) throws JSONException {
		JSONObject resultJson = new JSONObject(str);

		return resultJson;
	}

	public String getBootstrapSessionUrl(String vizqlRoot, String sessionId) {
		return configParameter.getTableauHostUrl() + vizqlRoot + "/bootstrapSession/sessions/" + sessionId;
	}

	// ExcelDownload------------------------------------------------------------------test
	public JSONObject getReportViewFirst(String url, TableauCredentialsType authToken) throws JSONException {
		// Creates the HTTP client object and makes the HTTP request to the
		// specified URL
		Client client = Client.create();
		WebResource webResource = client.resource(url);

		Cookie cookie = new Cookie("workgroup_session_id", authToken.getToken());
		// Sets the header and makes a GET request
		ClientResponse clientResponse = webResource.cookie(cookie).get(ClientResponse.class);

		// Parses the response from the server into an XML string
		String responseHtml = clientResponse.getEntity(String.class);
		Pattern pattern = null;

		pattern = Pattern.compile("<textarea id=\"tsConfigContainer\">(.*)</textarea>");

		Matcher match = pattern.matcher(responseHtml);

		String tsConfigContainer = null;

		if (match.find()) { // 패턴 매칭 확인
			tsConfigContainer = match.group(0);
		}
		// logger.debug("Response: \n" + tsConfigContainer);

		String decodeResult = tsConfigDecode(tsConfigContainer);
		JSONObject tsConfigContainerJson = tsConfigParser(decodeResult);

		return tsConfigContainerJson;
	}

	public String getReportViewFirst_under_10_3(String url, TableauCredentialsType authToken) throws JSONException {
		// Creates the HTTP client object and makes the HTTP request to the
		// specified URL
		Client client = Client.create();
		WebResource webResource = client.resource(url);

		Cookie cookie = new Cookie("workgroup_session_id", authToken.getToken());
		// Sets the header and makes a GET request
		ClientResponse clientResponse = webResource.cookie(cookie).get(ClientResponse.class);

		// Parses the response from the server into an XML string
		String responseHtml = clientResponse.getEntity(String.class);
		Pattern pattern = null;

		pattern = Pattern.compile("tsConfig = \\{(.+?)\\};", Pattern.DOTALL);

		Matcher match = pattern.matcher(responseHtml);

		String tsConfigContainer = null;

		if (match.find()) { // 패턴 매칭 확인
			tsConfigContainer = match.group(0);
		}
		// logger.debug("Response: \n" + tsConfigContainer);

		String decodeResult = tsConfigDecode_under_10_3(tsConfigContainer);

		return decodeResult;
	}

	public BootstrapRequest extractFirstResponse(JSONObject tsConfigContainer) throws JSONException {

		BootstrapRequest reqBootParam = new BootstrapRequest();

		String metrics = "{\"scrollbar\": {\"w\": 17,\"h\": 17},\"qfixed\": {\"w\": 0,\"h\": 0},\"qslider\": {\"w\": 0,\"h\": 20},\"qreadout\": {\"w\": 0,\"h\": 26},\"cfixed\": {\"w\": 0,\"h\": 1},\"citem\": {\"w\": 0,\"h\": 17},\"cmdropdown\": {\"w\": 0,\"h\": 24},\"cmslider\": {\"w\": 0,\"h\": 38},\"cmpattern\": {\"w\": 0,\"h\": 22},\"hfixed\": {\"w\": 0,\"h\": 21},\"hitem\": {\"w\": 0,\"h\": 20}}";
		metrics = metrics.replaceAll("\'", "\"");

		reqBootParam.setSessionId(tsConfigContainer.get("sessionid").toString());
		reqBootParam.setVizqlRoot(tsConfigContainer.get("vizql_root").toString());
		reqBootParam.setSheet_id(tsConfigContainer.get("sheetId").toString());
		reqBootParam.setWorkbookName(tsConfigContainer.get("workbookName").toString());
		reqBootParam.setVisible_sheets(tsConfigContainer.getJSONArray("visible_sheets"));
		reqBootParam.setRepository_urls(tsConfigContainer.getJSONArray("repository_urls"));
		reqBootParam.setLanguage(tsConfigContainer.get("language").toString());
		reqBootParam.setLocale(tsConfigContainer.get("locale").toString());
		reqBootParam.setShowParams(tsConfigContainer.get("showParams").toString().replaceAll("\'", "\""));

		return reqBootParam;
	}

	public BootstrapRequest extractFirstResponse_under_10_3(String decodeResult, String params) throws JSONException, UnsupportedEncodingException {

		BootstrapRequest reqBootParam = new BootstrapRequest();

		String metrics = "{\"scrollbar\": {\"w\": 17,\"h\": 17},\"qfixed\": {\"w\": 0,\"h\": 0},\"qslider\": {\"w\": 0,\"h\": 20},\"qreadout\": {\"w\": 0,\"h\": 26},\"cfixed\": {\"w\": 0,\"h\": 1},\"citem\": {\"w\": 0,\"h\": 17},\"cmdropdown\": {\"w\": 0,\"h\": 24},\"cmslider\": {\"w\": 0,\"h\": 38},\"cmpattern\": {\"w\": 0,\"h\": 22},\"hfixed\": {\"w\": 0,\"h\": 21},\"hitem\": {\"w\": 0,\"h\": 20}}";
		metrics = metrics.replaceAll("\'", "\"");

		reqBootParam.setSessionId(extractBootstrapParameters_under_10_3("sessionid", decodeResult));
		reqBootParam.setVizqlRoot(extractBootstrapParameters_under_10_3("vizql_root", decodeResult));
		reqBootParam.setSheet_id(extractBootstrapParameters_under_10_3("sheetId", decodeResult));
		reqBootParam.setWorkbookName(extractBootstrapParameters_under_10_3("workbookName", decodeResult));
		JSONArray visible_sheets = new JSONArray(extractBootstrapParameters_under_10_3("visible_sheets", decodeResult).replaceAll("\"", "").split(","));
		reqBootParam.setVisible_sheets(visible_sheets);
		JSONArray repository_urls = new JSONArray(extractBootstrapParameters_under_10_3("repository_urls", decodeResult).replaceAll("\"", "").split(","));
		reqBootParam.setRepository_urls(repository_urls);
		reqBootParam.setLanguage(extractBootstrapParameters_under_10_3("language", decodeResult));
		reqBootParam.setLocale(extractBootstrapParameters_under_10_3("locale", decodeResult));
		reqBootParam.setShowParams(extractBootstrapParameters_under_10_3("showParams", decodeResult));
		// reqBootParam.setShowParams(params);
		logger.debug(visible_sheets.toString());
		logger.debug(repository_urls.toString());

		return reqBootParam;
	}

	public String extractBootstrapParameters_under_10_3(String key, String decodeResult) throws UnsupportedEncodingException {
		Pattern pattern = null;
		pattern = Pattern.compile("\"?" + key + "\"?:\\s?(['\"\\[])(.*)['\"\\]],\\n");

		Matcher match = pattern.matcher(decodeResult);

		String value = "";
		if (match.find()) { // 패턴 매칭 확인
			value = match.group(2);
		}
		String decode = URLDecoder.decode(value, "UTF-8");
		return StringEscapeUtils.unescapeJava(decode);
	}

	public String getReportViewSecond(String url, BootstrapRequest reqBootParam, TableauCredentialsType authToken) {
		// Creates the HTTP client object and makes the HTTP request to the
		// specified URL
		Client client = Client.create();
		WebResource webResource = client.resource(url);

		String ACTIVE_TAB_HEADER = "X-Tsi-Active-Tab";
		String ACCEPT_LANGUAGE_HEADER = "Accept-Language";

		Cookie cookie = new Cookie("workgroup_session_id", authToken.getToken());

		MultivaluedMapImpl formData = new MultivaluedMapImpl();
		formData.add("sheet_id", reqBootParam.getSheet_id());
		formData.add("showParams", reqBootParam.getShowParams());
		formData.add("locale", reqBootParam.getLocale());
		formData.add("language", reqBootParam.getLanguage());
		logger.debug("showParams: " + reqBootParam.getShowParams());
		ClientResponse clientResponse = webResource.cookie(cookie).header(ACTIVE_TAB_HEADER, reqBootParam.getSheet_id()).header(ACCEPT_LANGUAGE_HEADER, "ko_KR")
				.post(ClientResponse.class, formData);

		// Parses the response from the server into an XML string
		String responseStr = clientResponse.getEntity(String.class);
		// logger.debug("Response: \n" + responseStr);

		return responseStr;
	}

	public BootstrapResponse extractSecondResponse(String secondResponse) throws JSONException {

		BootstrapResponse resBootParam = new BootstrapResponse();
		String extractJSONString = secondResponse;
		if (secondResponse.indexOf("{") >= 0) {
			extractJSONString = secondResponse.substring(secondResponse.indexOf("{"));
		}
		// JSONObject tsConfigContainer2 =
		// tsConfigParser(extractJSONString.replaceAll("\\\\\"", "'"));
		JSONObject tsConfigContainer2 = tsConfigParser(extractJSONString);

		String newSessionId = tsConfigContainer2.getString("newSessionId");
		JSONObject viewIds = tsConfigContainer2.getJSONObject("worldUpdate").getJSONObject("applicationPresModel").getJSONObject("workbookPresModel")
				.getJSONObject("dashboardPresModel").getJSONObject("viewIds");
		String sheetName = tsConfigContainer2.getJSONObject("worldUpdate").getJSONObject("applicationPresModel").getJSONObject("workbookPresModel")
				.getJSONObject("dashboardPresModel").getJSONObject("sheetLayoutInfo").getString("sheetName");

		Iterator<?> i = viewIds.keys();
		while (i.hasNext()) {
			String key = i.next().toString();
			logger.debug(key);
			logger.debug(viewIds.getString(key));
		}

		resBootParam.setNewSessionId(newSessionId);
		resBootParam.setViewIds(viewIds);
		resBootParam.setSheetName(sheetName);

		return resBootParam;
	}

	public WorkSheetType requestExtractCrossTab(String key, String url, TableauCredentialsType authToken) {
		WorkSheetType workSheetType = new WorkSheetType();
		Client client = Client.create();
		WebResource webResource = client.resource(url);

		Cookie cookie = new Cookie("workgroup_session_id", authToken.getToken());
		// Sets the header and makes a GET request
		ClientResponse clientResponse = webResource.cookie(cookie).get(ClientResponse.class);
		// Parses the response from the server into an XML string
		String responseHtml = clientResponse.getEntity(String.class);

		workSheetType.setName(key);
		workSheetType.setContents(responseHtml);

		return workSheetType;
	}

	// 엑셀 출력
	public boolean csvToXLSX(LinkedHashMap<String, WorkSheetList> workbookList, String downloadPath) {
		SXSSFWorkbook workBook = null;

		try {
			Iterator<String> keyData = workbookList.keySet().iterator();
			workBook = new SXSSFWorkbook();

			String xlsxFileAddress = downloadPath; // xlsx file address

			String filePath = FilenameUtils.getFullPath(xlsxFileAddress);
			File theDir = new File(filePath);

			if (!theDir.exists()) {
				theDir.mkdirs();
			}

			File d = new File(xlsxFileAddress);
			d.setExecutable(true, false);
			d.setReadable(true, false);
			d.setWritable(true, false);

			String expr = "^[-+]?(0|[0-9][0-9]*)(\\.[0-9]+)?([eE][-+]?[0-9]+)?$";
			Pattern pattern = Pattern.compile(expr);
			Matcher matcher = null;


			String sheetNm = null;// URLDecoder.decode(sheetName, "UTF-8");
			Sheet sheet    = null;// workBook.createSheet(sheetNm);
			// Excel Build Start
			while (keyData.hasNext()) {
				String sheetName = keyData.next().toString();
				logger.debug("WorkSheetList : " + sheetName);
				WorkSheetList workSheetList = workbookList.get(sheetName);
				int RowNum = 0;
				Row currentRow = null;


				for (int idx = 0; idx < workSheetList.getWorkSheet().size(); idx++) {

					String workSheetName = workSheetList.getWorkSheet().get(idx).getName();
					String workSheetContent = workSheetList.getWorkSheet().get(idx).getContents();
					
					sheetNm = URLDecoder.decode(workSheetName, "UTF-8");
					sheetNm = StringUtil.removeSpecialChar(sheetNm);
					sheet = workBook.createSheet(sheetNm);
					
					RowNum = sheet.getLastRowNum();

					String workSheetNm = URLDecoder.decode(workSheetName, "UTF-8");
					workSheetNm = StringUtil.removeSpecialChar(workSheetNm);
					logger.debug("workSheetName : " + workSheetNm);
					// logger.debug("workSheetContent : " + workSheetContent);

					String currentLine = null;

					// convert String into InputStream
					InputStream is = new ByteArrayInputStream(workSheetContent.getBytes());
					BufferedReader br = new BufferedReader(new InputStreamReader(is));
					currentRow = sheet.createRow(RowNum);
					currentRow.createCell(0).setCellValue(workSheetNm);
					while ((currentLine = br.readLine()) != null) {
						// String str[] = currentLine.split(",");
						String str[] = currentLine.split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)", -1);
						RowNum++;
						currentRow = sheet.createRow(RowNum);
						Cell cell = null;
						for (int i = 1; i < str.length + 1; i++) {// 한열 비우고 내용
																	// 시작
							String val = str[i - 1].replaceAll("\"", "").replaceAll(",", "").replaceAll("`", "");

							// currentRow.createCell(i).setCellValue(val);
							matcher = pattern.matcher(val);
							if (matcher.matches()) {
								cell = currentRow.createCell(i-1);
								cell.setCellType(CellType.NUMERIC);
								cell.setCellValue(Double.parseDouble(val));
							} else {
								cell = currentRow.createCell(i-1);
								cell.setCellValue(val);
							}
						}
					}

				}
			}
			FileOutputStream fileOutputStream = new FileOutputStream(xlsxFileAddress);
			workBook.write(fileOutputStream);
			fileOutputStream.close();
			logger.debug("Done");
			// Excel Build End
			return true;
		} catch (Exception ex) {
			System.out.println(ex.getMessage() + "Exception in try");

		} finally {
			if (workBook != null) {
				try {
					workBook.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return false;
	}

	public ArrayList<String> JSONArrayToArrayList(JSONArray arr) throws JSONException {
		ArrayList<String> list = new ArrayList<String>();
		if (arr != null) {
			int len = arr.length();
			for (int i = 0; i < len; i++) {
				list.add(arr.getString(i));
			}
		}
		return list;
	}

	public ArrayList<String> urlToVizRoot(ArrayList<String> arr) {
		ArrayList<String> list = new ArrayList<String>();
		if (arr != null) {
			int len = arr.size();

			for (int i = 0; i < len; i++) {
				String url[] = arr.get(i).toString().split("/");
				list.add("/vizql/w/" + url[0].trim() + "/v/" + url[1].trim());
			}
		}
		return list;
	}

	// private File getFile(String path) throws FileNotFoundException {
	// File file = new File(path);
	// if (!file.exists()) {
	// throw new FileNotFoundException("file with path: " + path + " was not
	// found.");
	// }
	// return file;
	// }

	/**
	 * 엑셀 public 디랙토리
	 * 
	 * @return
	 */
	public String getPublicDir() {
		return configParameter.getExcelPublicDir();
	}
}

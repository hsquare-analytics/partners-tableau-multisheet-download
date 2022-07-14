package com.planit.tableau.portal.standard.v1.excel.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONException;
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
import com.planit.tableau.portal.standard.v1.common.utils.pdf.PDFUtils;
import com.planit.tableau.portal.standard.v1.common.vo.CommonDefaultVO;
import com.planit.tableau.portal.standard.v1.tableau.bindings.TableauCredentialsType;
import com.planit.tableau.portal.standard.v1.tableau.command.TabCommand;
import com.planit.tableau.portal.standard.v1.tableau.restapi.RestApiUtils;

/**
 * 엑셀 다운로드
 * 
 * @author Planit-Partners
 */
@Controller
public class PdfDownload extends TableauBaseController {

	private static Logger logger = LoggerFactory.getLogger(PdfDownload.class);

	/**
	 * 태블로 인터페이스
	 */
	@Autowired
	RestApiUtils tableauAPI;

	@Autowired
	TabCommand tabCommand;

	/**
	 * config class
	 */
	@Autowired
	private ConfigParameter configParameter;

	private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");

	/**
	 * 엑셀 다운로드 파일
	 */
	@RequestMapping(value = "/pdf/downloadFile", method = { RequestMethod.POST, RequestMethod.GET })
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
	@PostMapping(value = "/pdf/download")
	//@Transactional
	public @ResponseBody CommonDefaultVO download(HttpServletRequest request, HttpServletResponse response) throws JSONException, IOException {

		// 로직 수정 필요 ##############
		// 결과 코드
		int resultCode = -1;
		// 결과 메시지
		String resultMessage = "";

		try {
			String params = HtmlUtils.htmlUnescape(request.getParameter("params"));
			logger.debug(params);

			String sheets_str = request.getParameter("sheets");
			String[] sheets = sheets_str.split("\\|\\|");
			String extractOption = request.getParameter("extractOption");
			boolean createPdfResult = false;
			String downloadPath = getPublicDir() + "/";// request.getServletContext().getRealPath("/");
			Timestamp timestamp = new Timestamp(System.currentTimeMillis());
			String fileName = "pdfDownload^_" + sdf.format(timestamp) + ".pdf";
			downloadPath += fileName; // xlsx file address

			// 사용자 세션에서 태블로 credentials 반환
			TableauCredentialsType credentials = getAdminCredentials();
			if (credentials == null) {
				resultCode = -1;
				// resultMessage = "인증정보가 없습니다. 확인 부탁드립니다.";
				resultMessage = getMessage("인증정보가_없습니다") + "\n" + getMessage("확인_부탁드립니다");
				logger.error("ExcelDownload - 관리자 인증정보가 없습니다.");
			} else {
				String urls = "";
				if (extractOption.equals("1")) {
					urls = sheets[0].split("/views")[1];
					createPdfResult = pdfDownload(urls, params, downloadPath, credentials);
				} else if (extractOption.equals("2")) {

					// Prepare input pdf file list as list of input stream.
					List<InputStream> inputPdfList = new ArrayList<InputStream>();

					// Prepare output stream for merged pdf file.
					File outputFile = new File(downloadPath);
					String downSheetPath = "";
					String[] urlsSplits = null;
					for (int i = 0; i < sheets.length; i++) {
						urls = sheets[i].split("/views")[1];
						urlsSplits = urls.split("/");
						downSheetPath = getPublicDir() + "/pdfDownload^_" + sdf.format(timestamp) + (urlsSplits[urlsSplits.length - 1]) + ".pdf";
						createPdfResult = pdfDownload(urls, params, downSheetPath, credentials);
						if (createPdfResult) {
							inputPdfList.add(new FileInputStream(downSheetPath));
						}
					}
					// merge
					createPdfResult = PDFUtils.mergePdfs(inputPdfList, outputFile);
				}
				// 성공
				if (createPdfResult) {
					resultCode = 0;
					resultMessage = fileName;
					// 실패
				} else {
					resultCode = -1;
					resultMessage = getMessage("시스템에러메시지");
				}
			}
		} catch (Exception e) {
			resultCode = -1;
			logger.error(e.getMessage());
		}

		return CommonDefaultVO.getNewInstance(resultCode, resultMessage);
	}

	/**
	 * PDF 다운로드 파일 생성..
	 * 
	 * @param exportUrl
	 * @param extractOption
	 * @param params
	 * @param downloadPath
	 * @param credentials
	 * @return
	 */
	private boolean pdfDownload(String sheets, String params, String downloadPath, TableauCredentialsType credentials) {

		// String adminId = configParameter.getTableauAdminName();
		// String adminPassword = configParameter.getTableauAdminPw();
		// String tableauHost = configParameter.getTableauHostUrl();
		try {
			params = URLDecoder.decode(params, "UTF-8");
			if (params.indexOf("?") == -1) {
				params = "?" + params;
			} else {
				params = "&" + params;
			}

			// params = URLEncoder.encode(params,"UTF-8");
			params = com.mysema.commons.lang.URLEncoder.encodeURL(params);

			sheets += params;
			StringBuffer cmdSb = new StringBuffer();
			cmdSb.append(" export ");
			cmdSb.append(" \"");
			cmdSb.append(sheets);
			cmdSb.append("\" ");
			cmdSb.append(" -pdf ");
			// cmdSb.append(" --pagelayout "+paygelayout+" "); // landscape or
			// portrait
			// cmdSb.append(" --pagesize "+pagesize+" "); // unspecified,
			// letter, legal, note folio, tabloid, ledger, statement, executive,
			// a3, a4, a5, b4, b5, or quarto

			// cmdSb.append(" -s " + tableauHost);
			// cmdSb.append(" -u " + adminId);
			// cmdSb.append(" -p " + adminPassword);
			cmdSb.append(" -f " + downloadPath);

			// PDF 생성...
			String result = tabCommand.doCommand(cmdSb.toString());

			if (result.indexOf("has been created") >= 0 || result.indexOf("저장함") >= 0) {
				return true;
			}

		} catch (Exception e) {
			logger.error(e.getMessage());
		}
		return false;

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
	 * PDF public 디랙토리
	 * 
	 * @return
	 */
	public String getPublicDir() {
		return configParameter.getExcelPublicDir();
	}
}

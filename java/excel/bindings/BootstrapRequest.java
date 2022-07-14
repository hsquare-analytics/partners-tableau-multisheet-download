package com.planit.tableau.portal.standard.v1.excel.bindings;

import org.json.JSONArray;

public class BootstrapRequest {
	/**
	 * sessionId
	 */
	private String sessionId;
	/**
	 * vizqlRoot
	 */
	private String vizqlRoot;
	/**
	 * sheetId
	 */
	private String sheet_id;
	
	private JSONArray visible_sheets;
	
	private JSONArray repository_urls;
	
	private String workbookName;

	
	/**
	 * showParams
	 */
	private String showParams;
	/**
	 * showParams
	 */
	private String language;
	
	/**
	 * showParams
	 */
	private String locale;
	/**
	 * showParams
	 */
	private String metrics;
	
	
	public String getSheet_id() {
		return sheet_id;
	}
	public void setSheet_id(String sheet_id) {
		this.sheet_id = sheet_id;
	}
	
	public String getSessionId() {
		return sessionId;
	}
	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
	}
	public String getVizqlRoot() {
		return vizqlRoot;
	}
	public void setVizqlRoot(String vizqlRoot) {
		this.vizqlRoot = vizqlRoot;
	}
	
	public String getShowParams() {
		return showParams;
	}
	public void setShowParams(String showParams) {
		this.showParams = showParams;
	}
	
	public String getLanguage() {
		return language;
	}
	public void setLanguage(String language) {
		this.language = language;
	}
	public String getLocale() {
		return locale;
	}
	public void setLocale(String locale) {
		this.locale = locale;
	}
	public String getMetrics() {
		return metrics;
	}
	public void setMetrics(String metrics) {
		this.metrics = metrics;
	}
	public JSONArray getVisible_sheets() {
		return visible_sheets;
	}
	public void setVisible_sheets(JSONArray visible_sheets) {
		this.visible_sheets = visible_sheets;
	}
	public JSONArray getRepository_urls() {
		return repository_urls;
	}
	public void setRepository_urls(JSONArray repository_urls) {
		this.repository_urls = repository_urls;
	}
	public String getWorkbookName() {
		return workbookName;
	}
	public void setWorkbookName(String workbookName) {
		this.workbookName = workbookName;
	}
	
}

package com.serotonin.mango.web.integration;

import java.text.MessageFormat;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.TimeZone;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.support.RequestContextUtils;

import com.serotonin.mango.Common;
import com.serotonin.mango.db.dao.UserDao;
import com.serotonin.mango.util.IpAddressMatcher;
import com.serotonin.mango.vo.User;
import org.scada_lts.serorepl.utils.StringUtils;

import br.org.scadabr.db.dao.UsersProfileDao;
import br.org.scadabr.vo.usersProfiles.UsersProfileVO;

public class VrocUtils {
	private static final Log LOG = LogFactory.getLog(VrocUtils.class);

	private static String X_WEBAUTH_USER = "x-webauth-user";
	private static String X_WEBAUTH_EMAIL = "x-webauth-email";
	private static String X_WEBAUTH_ROLE = "x_webauth_role";

	/**
	 * Checks if request is valid single sign-on request
	 * 
	 * @param request HTTP request object
	 * @return true if valid, false otherwise
	 */
	public static boolean isSingleSignOnRequest(HttpServletRequest request) {
		Set<String> headers = getHeaderValues(request);
		if (!headers.contains(X_WEBAUTH_USER))
			return false;

		// Check if request is from whitelisted IP address
		String whitelistedSubnet = getEnvironmentProperty("WEBAUTH_SUBNET");
		if (whitelistedSubnet != null && whitelistedSubnet.trim().length() > 0) {
			if (!new IpAddressMatcher(whitelistedSubnet).matches(request.getRemoteAddr()))
				return false;
		}

		return true;
	}

	/**
	 * Create user if does not already exist
	 * 
	 * @param request HTTP request object
	 */
	public static User createUser(HttpServletRequest request) {
		UserDao userDao = new UserDao();

		String userName = request.getHeader(X_WEBAUTH_USER);
		String email = request.getHeader(X_WEBAUTH_EMAIL);
		String role = request.getHeader(X_WEBAUTH_ROLE);

		User user = userDao.getUser(userName);
		if (user == null) {
			user = new User();
			user.setUsername(userName);
			if (email == null || email.equals("(null)")) {
				user.setEmail(userName);
			} else {
				user.setEmail(email);
			}
			user.setPassword(StringUtils.generateRandomString(30,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890!@#$%^&*()_+-=[];',./<>?:{}|"));
			user.setAdmin(false);
			user.setDisabled(false);
			user.setReceiveAlarmEmails(0);
			user.setReceiveOwnAuditEvents(true);
			TimeZone tz;
			if (RequestContextUtils.getTimeZone(request) == null) {
				tz = TimeZone.getDefault();
			} else {
				tz = RequestContextUtils.getTimeZone(request);
			}
			String originalID = tz.getID();

			int offset = tz.getRawOffset();
			
			String id = String.format("UTC%s%02d:%02d", 
               offset < 0 ? "-" : "+", 
               Math.abs(offset) / 3600000,
               Math.abs(offset) / 60000 % 60);
			tz.setID(id);
			user.setTimezone(tz);
			user.setZone(originalID);
			userDao.saveUser(user);

			UsersProfileDao usersProfileDao = new UsersProfileDao();
			usersProfileDao.getUsersProfiles();
			UsersProfileVO profile = usersProfileDao.getUserProfileByName(role);
			if (profile != null) {
				profile.apply(user);
				usersProfileDao.resetUserProfile(user);
				usersProfileDao.updateUsersProfile(profile);
			}
			userDao.saveUser(user);
		}

		user.setSingleSignedOn(true);
		return user;
	}

	/**
	 * Logs out user
	 * 
	 * @return URL to redirect user
	 */
	public static String logout() {
		String redirectUrl = getEnvironmentProperty("WEBAUTH_LOGOUT_URL");
		return redirectUrl;
	}

	private static Set<String> getHeaderValues(HttpServletRequest request) {
		Set<String> headers = new HashSet<String>(Collections.list(request.getHeaderNames()));

		for (String header : headers) {
			LOG.debug(MessageFormat.format("{0}:{1}", header, request.getHeader(header)));
		}
		return headers;
	}

	/**
	 * Returns value of property by first looking at environment variable and
	 * falling back to env.properties file
	 * 
	 * @param key Property key
	 * @return Property value
	 */
	@SuppressWarnings("deprecation")
	private static String getEnvironmentProperty(String key) {
		String val = System.getenv(key);
		if (val == null)
			val = Common.getEnvironmentProfile().getString(key, null);
		return val;
	}
}

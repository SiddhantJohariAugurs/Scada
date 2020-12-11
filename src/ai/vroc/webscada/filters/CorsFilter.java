package ai.vroc.webscada.filters;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet Filter implementation class CorsFilter
 */
@WebFilter
public class CorsFilter implements Filter {
	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {
		// method must be implemented for Filter interface
	}

	/**
	 * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	 */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		HttpServletRequest httpServletRequest = (HttpServletRequest) request;
		HttpServletResponse httpServletResponse = (HttpServletResponse) response;
		// Authorize (allow) all domains to consume the content
		if (httpServletRequest.getHeader("Origin") != null && httpServletRequest.getHeader("Origin").contains("://localhost")) {
			httpServletResponse.addHeader("Access-Control-Allow-Origin", httpServletRequest.getHeader("Origin"));
			httpServletResponse.addHeader("Access-Control-Allow-Methods","GET, OPTIONS, HEAD, PUT, POST");
			httpServletResponse.addHeader("Access-Control-Allow-Credentials","true");
			httpServletResponse.setHeader("Access-Control-Allow-Headers", "Content-Type");
	        if (httpServletRequest.getMethod().equals("OPTIONS")) {
	        	httpServletResponse.setStatus(HttpServletResponse.SC_ACCEPTED);
	            return;
	        }
		}
		// pass the request along the filter chain
		chain.doFilter(request, httpServletResponse);
	}

	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig fConfig) throws ServletException {
		// method must be implemented for Filter interface
	}

}

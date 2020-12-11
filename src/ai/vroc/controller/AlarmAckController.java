package ai.vroc.controller;

import java.text.MessageFormat;
import java.util.HashMap;
import java.util.Map;
import java.util.ResourceBundle;

import javax.servlet.http.HttpServletRequest;

import org.scada_lts.mango.service.EventService;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.serotonin.mango.Common;
import com.serotonin.mango.rt.event.EventInstance;
import com.serotonin.mango.vo.User;
import com.serotonin.mango.web.dwr.MiscDwr;

@Controller
public class AlarmAckController {

	MiscDwr miscDwr;

	public AlarmAckController(ApplicationContext applicationContext) {
		miscDwr = (MiscDwr) applicationContext.getBean("MiscDwr");
	}

	@RequestMapping(value = "/alarm_ack.shtm", method = RequestMethod.GET)
	public ModelAndView ackAlarm(HttpServletRequest request) throws Exception {
		int alarmId = Integer.parseInt(request.getParameter("alarmId"));
		User user = Common.getUser(request);
		if (user == null) {
			request.getSession().setAttribute("url_prior_login",
					MessageFormat.format("alarm_ack.shtm?alarmId={0}", alarmId));
			return new ModelAndView("redirect:/login.htm");
		} else {
			miscDwr.acknowledgeEvent(alarmId);
		}

		Map<String, Object> model = new HashMap<String, Object>();
		
		try {
			EventInstance evt = new EventService().getById(alarmId);
			
			if(evt != null) {
				ResourceBundle bundle = Common.getBundle();
				model.put("evt", evt.getMessage().getLocalizedMessage(bundle));
			}
			
		} catch (Exception e) {
			// ignore exception
			model.put("evt", "");
		}
		
		return new ModelAndView("alarmAck", model);
	}
}

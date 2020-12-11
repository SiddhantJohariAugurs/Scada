package com.serotonin.mango.view.component;

import java.util.ResourceBundle;

import com.serotonin.json.JsonRemoteEntity;
import com.serotonin.mango.rt.RuntimeManager;
import com.serotonin.mango.rt.dataImage.DataPointRT;
import com.serotonin.mango.rt.dataImage.PointValueTime;
import com.serotonin.mango.view.ImplDefinition;
import com.serotonin.mango.vo.DataPointVO;

@JsonRemoteEntity
public class AnalogCompoundComponent extends CompoundComponent {
	private static final long serialVersionUID = 1L;
	public static ImplDefinition DEFINITION = new ImplDefinition("analogCompound", "ANALOG_COMPOUND",
			"graphic.analogCompound", null);

	public static final String POINT_1 = "point1";
	public static final String POINT_2 = "point2";
	public static final String POINT_3 = "point3";

	public AnalogCompoundComponent() {
		initialize();
	}

	@Override
	protected void initialize() {
		addChild(POINT_1, "graphic.analogCompound." + POINT_1, createComponent(), null);
		addChild(POINT_2, "graphic.analogCompound." + POINT_2, createComponent(), null);
		addChild(POINT_3, "graphic.analogCompound." + POINT_3, createComponent(), null);
	}

	@Override
	public boolean hasInfo() {
		return false;
	}

	private SimplePointComponent createComponent() {
		SimplePointComponent c = new SimplePointComponent();
		c.setLocation(0, 0);
		c.setStyle("position:relative;");
		c.setDisplayControls(false);
		c.setSettableOverride(true);
		c.setDisplayPointName(true);
		c.setBkgdColorOverride("transparent");
		return c;
	}

	@Override
	public ImplDefinition definition() {
		return DEFINITION;
	}

	@Override
	public String getStaticContent() {
		return null;
	}

	@Override
	public boolean isDisplayImageChart() {
		return false;
	}

	@Override
	public String getImageChartData(ResourceBundle bundle) {
		return null;
	}

	public String getImage(RuntimeManager rtm) {
		DataPointVO pointRunning = ((PointComponent) this.getChildComponents().get(0).getViewComponent()).tgetDataPoint();
		DataPointVO pointMode = ((PointComponent) this.getChildComponents().get(1).getViewComponent()).tgetDataPoint();
		DataPointVO pointUnavailable = ((PointComponent) this.getChildComponents().get(2).getViewComponent()).tgetDataPoint();

		if (pointRunning == null || pointMode == null || pointUnavailable == null)
			return null;
		
		DataPointRT dataPointRTRunning = rtm.getDataPoint(pointRunning.getId());
		DataPointRT dataPointRTMode = rtm.getDataPoint(pointMode.getId());
		DataPointRT dataPointRTUnavailable = rtm.getDataPoint(pointUnavailable.getId());
		
		if(dataPointRTRunning == null || dataPointRTMode == null || dataPointRTUnavailable == null)
			return null;
		
		PointValueTime r = dataPointRTRunning.getPointValue();
		PointValueTime m = dataPointRTMode.getPointValue();
		PointValueTime u = dataPointRTUnavailable.getPointValue();
		
		if(r != null && m != null && u != null) {
			if(m.getIntegerValue() == 3 || u.getBooleanValue() == true) {
				return "graphics/PumpFaulty/faulty.png";
			}
			
			if(r.getBooleanValue()) {
				return "graphics/PumpFaulty/on.png";
			}
			
			return "graphics/PumpFaulty/off.png";
		}
		return null;
	}
}

package com.serotonin.mango.view.component;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import com.serotonin.json.JsonRemoteEntity;
import com.serotonin.json.JsonRemoteProperty;
import com.serotonin.mango.view.ImplDefinition;
import com.serotonin.mango.vo.User;
import com.serotonin.util.SerializationHelper;

@JsonRemoteEntity
public class CalendarComponent extends ViewComponent {
	public static ImplDefinition DEFINITION = new ImplDefinition("calendar",
			"CALENDAR", "graphic.calendar", null);
    
	@JsonRemoteProperty
	private String content = "{}";

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
 
    @Override
	public ImplDefinition definition() {
		return DEFINITION;
	}

    public static final Boolean pointComponent = false;
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.writeInt(serialVersionUID);

        SerializationHelper.writeSafeUTF(out, getContent());
    }

    private void readObject(ObjectInputStream in) throws IOException {
        int ver = in.readInt();

        // Switch on the version of the class so that version changes can be elegantly handled.
        if (ver == 1)
            setContent(SerializationHelper.readSafeUTF(in));
    }
	//
	// /
	// / Serialization
	// /
	//
	private static final int serialVersionUID = 1;

	@Override
	public void validateDataPoint(User user, boolean makeReadOnly) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean isVisible() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public boolean isValid() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public boolean containsValidVisibleDataPoint(int dataPointId) {
		// TODO Auto-generated method stub
		return false;
	}
}

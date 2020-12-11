package org.scada_lts.dao;
import java.util.*;
public class LayerBean implements java.io.Serializable
{
    private String layerName;
    private String layerDescription;
    private int layerId;
    LayerBean()
    {
        this.layerName="";
        this.layerDescription="";
        this.layerId=0;
    }
    public void setLayerId(int layerId)
    {
        this.layerId=layerId;
    }
    public int getLayerId()
    {
        return this.layerId;
    }
    public void setLayerName(String layerName)
    {
        this.layerName=layerName;
    }
    public void setLayerDescription(String layerDescription)
    {
        this.layerDescription=layerDescription;
    }
    public String getLayerName()
    {
        return this.layerName;
    }
    public String getLayerDescription()
    {
        return this.layerDescription;
    }
}

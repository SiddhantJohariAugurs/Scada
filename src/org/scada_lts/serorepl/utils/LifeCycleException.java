package org.scada_lts.serorepl.utils;

public class LifeCycleException extends Exception{

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public LifeCycleException(){}

    public LifeCycleException(String msg, Throwable reason){
        super(msg, reason);
    }

    public LifeCycleException(String msg) {
        super(msg);
    }

    public LifeCycleException(Throwable reason) {
        super(reason);
    }

}

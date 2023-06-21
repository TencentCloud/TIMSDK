package com.tencent.qcloud.tuicore.interfaces;

public class TUILoginConfig {
    /**
     * ## Do not output any SDK logs
     */
    public static final int TUI_LOG_NONE = 0;
    /**
     * ## Output logs at the DEBUG, INFO, WARNING, and ERROR levels
     */
    public static final int TUI_LOG_DEBUG = 3;
    /**
     * ## Output logs at the INFO, WARNING, and ERROR levels
     */
    public static final int TUI_LOG_INFO = 4;
    /**
     * ## Output logs at the WARNING and ERROR levels
     */
    public static final int TUI_LOG_WARN = 5;
    /**
     * ## Output logs at the ERROR level
     */
    public static final int TUI_LOG_ERROR = 6;

    // Log level
    private int logLevel = TUI_LOG_INFO;

    // Log callback
    private TUILogListener tuiLogListener;

    /**
     * Configuration class constructor
     */
    public TUILoginConfig() {}

    /**
     * Set the write log level. This operation must be performed before IM SDK initialization. Otherwise, the setting does not take effect.
     *
     * @param logLevel   Log level
     */
    public void setLogLevel(int logLevel) {
        this.logLevel = logLevel;
    }

    public int getLogLevel() {
        return this.logLevel;
    }

    /**
     * Get the current log callback listener
     */
    public TUILogListener getLogListener() {
        return tuiLogListener;
    }

    /**
     * Set the current log callback listener. This operation must be performed before IM SDK initialization.
     * @note The callback is in the main thread. Log callbacks can be quite frequent, so be careful not to synchronize too many time-consuming tasks in the
     * callback, which may block the main thread.
     */
    public void setLogListener(TUILogListener logListener) {
        this.tuiLogListener = logListener;
    }
}

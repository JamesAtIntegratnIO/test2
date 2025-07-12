package logger

import (
    "os"
    "strings"

    "github.com/sirupsen/logrus"
)

// Logger interface for the application
type Logger interface {
    Debug(args ...interface{})
    Info(args ...interface{})
    Warn(args ...interface{})
    Error(args ...interface{})
    Fatal(args ...interface{})
    Debugf(format string, args ...interface{})
    Infof(format string, args ...interface{})
    Warnf(format string, args ...interface{})
    Errorf(format string, args ...interface{})
    Fatalf(format string, args ...interface{})
    WithField(key string, value interface{}) Logger
    WithFields(fields map[string]interface{}) Logger
}

// logrusLogger is a wrapper around logrus.Logger that implements our Logger interface
type logrusLogger struct {
    logger *logrus.Logger
    entry  *logrus.Entry
}

// New creates a new logger instance
func New() Logger {
    logger := logrus.New()
    
    // Configure formatter
    level := strings.ToLower(os.Getenv("LOG_LEVEL"))
    if level == "" {
        level = "info"
    }
    
    format := strings.ToLower(os.Getenv("LOG_FORMAT"))
    if format == "json" {
        logger.SetFormatter(&logrus.JSONFormatter{
            TimestampFormat: "2006-01-02 15:04:05",
        })
    } else {
        logger.SetFormatter(&logrus.TextFormatter{
            FullTimestamp:   true,
            TimestampFormat: "2006-01-02 15:04:05",
        })
    }
    
    // Set log level
    if logLevel, err := logrus.ParseLevel(level); err == nil {
        logger.SetLevel(logLevel)
    } else {
        logger.SetLevel(logrus.InfoLevel)
    }
    
    return &logrusLogger{
        logger: logger,
        entry:  logger.WithFields(logrus.Fields{}),
    }
}

// Debug logs a debug message
func (l *logrusLogger) Debug(args ...interface{}) {
    l.entry.Debug(args...)
}

// Info logs an info message
func (l *logrusLogger) Info(args ...interface{}) {
    l.entry.Info(args...)
}

// Warn logs a warning message
func (l *logrusLogger) Warn(args ...interface{}) {
    l.entry.Warn(args...)
}

// Error logs an error message
func (l *logrusLogger) Error(args ...interface{}) {
    l.entry.Error(args...)
}

// Fatal logs a fatal message
func (l *logrusLogger) Fatal(args ...interface{}) {
    l.entry.Fatal(args...)
}

// Debugf logs a formatted debug message
func (l *logrusLogger) Debugf(format string, args ...interface{}) {
    l.entry.Debugf(format, args...)
}

// Infof logs a formatted info message
func (l *logrusLogger) Infof(format string, args ...interface{}) {
    l.entry.Infof(format, args...)
}

// Warnf logs a formatted warning message
func (l *logrusLogger) Warnf(format string, args ...interface{}) {
    l.entry.Warnf(format, args...)
}

// Errorf logs a formatted error message
func (l *logrusLogger) Errorf(format string, args ...interface{}) {
    l.entry.Errorf(format, args...)
}

// Fatalf logs a formatted fatal message
func (l *logrusLogger) Fatalf(format string, args ...interface{}) {
    l.entry.Fatalf(format, args...)
}

// WithField adds a field to the logger
func (l *logrusLogger) WithField(key string, value interface{}) Logger {
    return &logrusLogger{
        logger: l.logger,
        entry:  l.entry.WithField(key, value),
    }
}

// WithFields adds multiple fields to the logger
func (l *logrusLogger) WithFields(fields map[string]interface{}) Logger {
    return &logrusLogger{
        logger: l.logger,
        entry:  l.entry.WithFields(fields),
    }
}

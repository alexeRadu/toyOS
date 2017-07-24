#ifndef VSNPRINTF_H
#define VSNPRINTF_H

#include <stdarg.h>

int vsnprintf(char *buf, int size, const char *fmt, va_list args);
int snprintf(char *buf, int size, const char *fmt, ...);

#endif /* VSNPRINTF_H */

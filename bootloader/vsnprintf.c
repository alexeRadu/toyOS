__asm__(".code16gcc\n");

#include <stdarg.h>

int vsnprintf(char *buf, int size, const char *fmt, va_list args)
{
	return 0;
}

int snprintf(char *buf, int size, const char *fmt, ...)
{
	va_list vl;
	int ret;

	va_start(vl, fmt);
	ret = vsnprintf(buf, size, fmt, vl);
	va_end(vl);

	return ret;
}
